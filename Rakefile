require 'bundler'
env = ENV['RACK_ENV'].nil? ? :development : ENV['RACK_ENV'].to_sym

Bundler.require(:default, env)
set :environment, env

desc 'Runs a develop webserver'
task :server do
  puts `rerun -- rackup --port 9292 config.ru`
end
