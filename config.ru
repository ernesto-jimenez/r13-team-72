require File.join(File.dirname(__FILE__), 'app', 'app.rb')
require 'resque/server'

Resque::Server.use(Rack::Auth::Basic) do |user, password|
    password == ENV["RESQUE_PASSWORD"]
end if ENV["RESQUE_PASSWORD"]

run Rack::URLMap.new \
  "/"       => Sinatra::Application,
  "/resque" => Resque::Server.new

