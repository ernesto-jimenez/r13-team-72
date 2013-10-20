require 'mongoid'
Mongoid.load!(File.join(__dir__, 'config', 'mongoid.yml'))
Dir['./app/models/*.rb'].each { |file| require file }
Dir['./app/services/*.rb'].each { |file| require file }

