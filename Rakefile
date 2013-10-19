require 'bundler'
env = (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :development).to_sym

Bundler.require(:default, env)
set :environment, env

require 'resque/tasks'
Dir["./app/workers/*.rb"].each {|file| require file }

desc 'Runs a develop webserver'
task :server do
  puts `rerun -- rackup --port 9292 config.ru`
end

desc 'Queue repository to fetch'
task :queue_repo, :repo, :last_commit do |t, args|
  Resque.enqueue(FetchRepo, args[:repo], args[:last_commit])
end

