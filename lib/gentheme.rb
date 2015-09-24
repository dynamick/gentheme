require 'erb'
require 'fileutils'
require 'tty'
require 'tty-which'
require 'yaml'
require 'mysql2'

require "gentheme/version"

module Gentheme
  class Generator

    attr_reader :root_path

    def initialize(name, options)
      @name = name
      @root_path = options[:path]
      @verbose = options[:verbose]
      @npm = false
      @wp_cli = false
      @virtualhost = false

      @status_file = "gentheme.conf"
      @default_status = {
          general: {
              project_name: name,
              generator: 'gentheme',
              generator_version: Gentheme::VERSION,
              created_at: Time.now,
              updated_at: Time.now
          },
          mysql: {
              db_host: "127.0.0.1",
              db_user: "root",
              db_pass: "",
              db_name: name
          },
          packages: {

          }}
      @status = read_status
      @status = @default_status if @status.nil?
    end


    def start

      if check_requirements



        # Create database
        if !get_status(:create_database, :packages)
          create_database
        else
          puts 'Database already created.'
        end

        # Install gulp-webapp
        if !get_status(:gulp_webapp, :packages)
          install_gulp_webapp if install_yeoman
        else
          puts 'Gulp-webapp is already installed'
        end

        #install wordpress
        if !get_status(:wordpress, :packages)
          install_wordpress
        else
          puts 'Wordpress is already installed'
        end

        # append wp gitignore
        if !get_status(:wp_gitignore, :packages)
          add_wp_gitignore
        else
          puts 'Wordpress is already added to gitignore'
        end

        # create a virtualhost
        if !get_status(:virtualhost, :packages)
          create_virtualhost
        else
          puts 'Virtualhost already created'
        end

        # create a starter theme
        if !get_status(:starter_theme, :packages)
          create_starter_theme
        else
          puts 'Starter theme already created'
        end


      end
    end


    def get_status(field, namespace)
      if read_status && !namespace.nil? && !field.nil?
        @status[namespace.to_sym][field.to_sym]
      else
        nil
      end
    end

    def set_status(field, value, namespace)
      if !namespace.nil? && !field.nil?
        @status[namespace.to_sym][field.to_sym] = value
        write_status
      else
        nil
      end
    end

    def read_status
      YAML::load_file("#{base_path}/#{@status_file}") rescue nil
    end

    def write_status
      system("#{enter_base_path}")
      File.open("#{base_path}/#{@status_file}", 'w') { |f| f.puts @status.to_yaml }
    end


    def name
      sanitized_name
    end


    def say_hello
      shell = TTY::Shell.new
      answer = shell.ask "What is your name?" do
        argument :required
        default 'Piotr'
        validate /\w+\s\w+/
        #valid    ['Piotr', 'Piotrek']
        modify :capitalize
      end.read_string
      puts "Hello world! #{@name}, this is your answer: #{answer}"
    end

    def check_requirements
      @npm = TTY::Which.which('npm')
      @wp_cli = TTY::Which.which('wp')
      @virtualhost = TTY::Which.which('virtualhost.sh')
      satisfy_requirements = (@npm.empty? && @wp_cli.empty? ? false : true)
      if !satisfy_requirements
        puts 'Error: Before proceding, you\'ve to install:'
        puts '- npm: Node.js Packet Manager ' if @npm.empty?
        puts '- wp_cli: Wordpress Command Line Tool ' if @wp_cli.empty?
        puts '- virtualhost.sh: add a virtual host to your apache conf' if @virtualhost.empty?
      else
        puts 'Requirement satisfied! Good, now we could proceed installing wp...'
      end
      return satisfy_requirements
    end

    def create_database
      if !get_status(:create_database, :packages)
        puts 'Creating database'
        db_host = get_status(:db_host, :mysql)
        db_user = get_status(:db_user, :mysql)
        db_pass = get_status(:db_pass, :mysql)
        db_name = get_status(:db_name, :mysql)
        client = Mysql2::Client.new(:host => db_host, :username => db_user, :password => db_pass)
        if client
          client.query("DROP DATABASE IF EXISTS #{db_name}")
          client.query("CREATE DATABASE #{db_name}")
          client.close
          set_status(:gulp_webapp, true, :packages)
        else
          puts "Can't connect to your database."
          puts "Please edit #{@base_root}/gentheme.conf your mysql account connection."
        end
      else
        puts "Database already created!"
      end

    end


    def install_yeoman
      installed_packages = []
      yo = false
      generator = false
      installed = get_status(:yeoman, :packages)
      if installed
        puts 'Yeoman already installed...'
        return true
      else
        if !@npm.empty?
          puts 'Checking for yeoman and generator-gulp-webapp generator...'
          #{}`#{npm} install --global yo generator-gulp-webapp`
          result = `#{@npm} ll  --global --parseable --silent yo generator-gulp-webapp`
          raw_installed_packages = result.split("\n")
          raw_installed_packages.each do |packs|
            p = packs.split(':')
            name = p[1].split('@')[0]
            path = p[0]
            version = p[1].split('@')[1]
            installed_packages << {name: name, path: path, version: version}

            generator = true if name == 'generator-gulp-webapp'
            yo = true if name == 'yo'
          end
          if generator == false || yo == false
            puts "Installing #{'yo' if !yo} #{'generator-gulp-webapp' if !generator}..."
            result = system("#{@npm} install --silent #{'yo' if !yo} #{'generator-gulp-webapp' if !generator}")
            puts result
          else
            puts 'OK: yeoman and generator-gulp-webapp found on your system'
          end
          set_status(:yeoman, true, :packages)
          return true
        else
          puts 'Error: npm not found on you system.'
          return false
        end
      end
    end

    def install_gulp_webapp
      if !get_status(:gulp_webapp, :packages)
        puts 'Installing gulp-webapp scaffold...'
        system("#{enter_base_path} && yo gulp-webapp")
        set_status(:gulp_webapp, true, :packages)
      end
    end

    def install_wordpress
      puts 'Installing Wordpress...'
      if @wp_cli && !get_status(:wordpress, :packages)
        system("#{enter_base_path} && mkdir -p wordpress && #{@wp_cli} core download --path=./wordpress/")
        set_status(:wordpress, true, :packages)
      end

    end

    def add_wp_gitignore
      puts 'appending wordpress to gitignore...'
      if !get_status(:wp_gitignore, :packages)
        system("#{enter_base_path} && echo '## Mac\n.DS_Store\n\n## WordPress\nwordpress\n' >> .gitignore")
        set_status(:wp_gitignore, true, :packages)
      end

    end

    def create_virtualhost
      puts 'Creating virtualhost...'
      if @virtualhost && !get_status(:virtualhost, :packages)
        system("virtualhost.sh #{name} #{base_path}/wordpress")
        set_status(:virtualhost, true, :packages)
      end

    end

    def create_starter_theme
      puts 'Creating starter theme...'
      if !get_status(:starter_theme, :packages)
        system("#{enter_base_path} && cd wordpress && wp core config --dbname=#{name} --dbuser=root --dbhost=127.0.0.1 --skip-check")
        system("#{enter_base_path} && cd wordpress && wp core install --title=#{name} --admin_user=admin --admin_password=#{name} --admin_email=youremail@#{name}.example.com --url=http://#{name} ")
        system("#{enter_base_path} && rm wordpress/wp-content/themes/#{name}")
        system("#{enter_base_path} && mv app app_#{rand(10000)}")
        system("#{enter_base_path} && mkdir app")
        system("#{enter_base_path} && cd wordpress && wp scaffold _s #{name}  --activate")
        system("#{enter_base_path} && mv wordpress/wp-content/themes/#{name}/* app/")
        system("#{enter_base_path} && rmdir wordpress/wp-content/themes/#{name}")
        system("#{enter_base_path} && ln -s #{base_path}/app/ wordpress/wp-content/themes/#{name}")
        set_status(:starter_theme, true, :packages)
      end

    end

    private

    def base_path
      File.join(@root_path, @name)
    end

    def enter_base_path
      cmd = "mkdir -p #{base_path} && cd $_"
      #{}`#{cmd}`
      #cmd
    end


    def sanitized_name
      @name.gsub(/([A-Z])([a-z])/, '_\1\2').sub(/^_/, '').downcase
    end


  end


end
