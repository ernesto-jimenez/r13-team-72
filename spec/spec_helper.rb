require 'bundler'

Bundler.require(:default, :test)

set :environment, :test
require_relative '../app/config'
require 'rspec/mocks/standalone'

RSpec.configure do |config|
  config.before(:all) do
    # ...
  end
  config.before(:each) do
    # ...
  end
end
