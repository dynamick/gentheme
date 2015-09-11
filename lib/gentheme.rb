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

    def install_yeoman
      npm = TTY::Which.which('npm')
      unless npm.nil?
        `#{npm} install --global yo generator-gulp-webapp`
      end

    end


    private

    def sanitized_name
      @name.gsub(/([A-Z])([a-z])/, '_\1\2').sub(/^_/, '').downcase
    end


  end


end
