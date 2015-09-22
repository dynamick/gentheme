require 'erb'
require 'fileutils'
require 'tty'
require 'tty-which'
require "gentheme/version"

module Gentheme
  class Generator

    attr_reader :root_path

    def initialize(path, name)
      @root_path = path
      @name      = name
      @npm       = false
      @wp_cli    = false
    end

    def name
      sanitized_name
    end

    def say_hello
      shell  = TTY::Shell.new
      answer = shell.ask "What is your name?" do
        argument :required
        default  'Piotr'
        validate /\w+\s\w+/
        #valid    ['Piotr', 'Piotrek']
        modify   :capitalize
      end.read_string
      puts "Hello world! #{@name}, this is your answer: #{answer}"
    end

    def check_requirements
      @npm    = TTY::Which.which('npm')
      @wp_cli = TTY::Which.which('wp')
      satisfy_requirements = ( @npm.empty? && @wp_cli.empty? ? false : true )
      if !satisfy_requirements
        puts 'Error: Before proceding, you\'ve to install:'
        puts '- npm: Node.js Packet Manager ' if @npm.empty?
        puts '- wp_cli: Wordpress Command Line Tool ' if @wp_cli.empty?
      else
        puts 'Requirement satisfied! Good, now we could proceed installing wp...'
      end
      return satisfy_requirements
    end


    def install_yeoman
      installed_packages  = []
      yo                  = false
      generator           = false
      unless @npm.empty?
        puts 'Checking for yeoman and generator-gulp-webapp generator...'
        #{}`#{npm} install --global yo generator-gulp-webapp`
        result = `#{@npm} ll  --global --parseable --silent yo generator-gulp-webapp`
        raw_installed_packages =  result.split("\n")
        raw_installed_packages.each do |packs|
          p = packs.split(':')
          name = p[1].split('@')[0]
          path = p[0]
          version = p[1].split('@')[1]
          installed_packages << { name: name, path: path, version: version }

          generator = true if name == 'generator-gulp-webapp'
          yo        = true if name == 'yo'
        end
        if generator == false || yo == false
          puts "Installing #{'yo' if !yo} #{'generator-gulp-webapp' if !generator}..."
          result = `#{@npm} install --silent #{'yo' if !yo} #{'generator-gulp-webapp' if !generator}`
          puts result
        else
          puts 'OK: yeoman and generator-gulp-webapp found on your system'
        end
        return true
      else
        puts 'Error: npm not found on you system.'
        return false
      end

    end

    def run_yeoman
      puts 'Installing gulp-webapp scaffold...'
      `yo gulp-webapp`
    end

    def prepare_wordpress
      puts 'Installing Wordpress...'
      if @wp_cli
        `mkdir wordpress`
        `#{@wp_cli} core download --path=./wordpress/`
      end

    end

    private

    def sanitized_name
      @name.gsub(/([A-Z])([a-z])/, '_\1\2').sub(/^_/, '').downcase
    end


  end


end
