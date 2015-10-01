# Gentheme

This ruby gem make available a shell command, "gentheme" which will permit you to generate a wordpress theme designed for theme authors.

## Requirements

This gem was tested only on OSX systems, so no warranties are given on other systems. 
The requirements needed to be already installed on the system are:
- npm: node.js and his packet manager
- virtualhost.sh: a simple shell script that permit to write etc/hosts and etc/apache2/virtualhost to create the virtual host
- wp_cli: a shell command for manage wordpress installations
- mysql server: you've to run the server

Before start gentheme make sure you've all the requirements installed and working.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gentheme'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gentheme

## Usage

Run 

```gentheme install themename``` 

to create a folder ```themename``` inside which will be all the resources. The installation process could take some minutes because all resources are downloaded from the internet and there are a lot of npm packages required. 

Once finished, open your broser at ```http://themename``` and you'll see your starter theme.

Use the option ```--path=./``` to install the app without creating a folder named as theme name.

## Structure

The theme is created in the ```themename/app``` folder. 

A Wordpress is installed in the ```themename/wordpress``` folder.

Wordpress is already installed and the theme is already activated on it.

## Start editing your theme

Follow the instructions at [gulp-webapp](https://github.com/yeoman/generator-gulp-webapp) to start editing your theme.
Remember that your theme is a [Underscore Theme](http://underscores.me/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dynamick/gentheme. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

