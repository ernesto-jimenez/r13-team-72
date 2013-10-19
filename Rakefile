require 'bundler'
env = (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :development).to_sym

Bundler.require(:default, env)
set :environment, env

require 'resque/tasks'
Dir["app/**/*.rb"].each {|file| require_relative file }

desc 'Runs a develop webserver'
task :server do
  puts `rerun -- rackup --port 9292 config.ru`
end

desc 'Queue repository to fetch'
task :queue_repo, :repo do |t, args|
  repo = Repository.from_url(args[:repo])
  Resque.enqueue(FetchRepo, repo.id)
end

