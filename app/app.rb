require 'bundler'

env = ENV['RACK_ENV'].nil? ? :development : ENV['RACK_ENV'].to_sym
Bundler.require(:default, env)
set :environment, env

require_relative 'config'

# require models
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each do |x|
  require x
end

# require helpers
Dir[File.join(File.dirname(__FILE__), 'helpers', '*.rb')].each do |x|
  require x
end

# require controllers
Dir[File.join(File.dirname(__FILE__), 'controllers', '*.rb')].each do |x|
  require x
end
