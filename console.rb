require 'mongoid'
Mongoid.load!(File.join(__dir__, 'config', 'mongoid.yml'))
require './app/models/repository.rb'
