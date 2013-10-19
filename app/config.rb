require 'sass/plugin/rack'

configure do
  # general
  use Rack::Session::Cookie, :secret => ENV['APP_SECRET'] ||
    '7ad377314cd2a6692b25b8fb12a'
  set :public_folder, File.join(settings.root, '..', 'public')

  # sass
  # in public/stylesheets/sass/ by default
  Sass::Plugin.options[:template_location] = File.join(
    settings.public_folder, 'sass')

  # partials plugin
  set :partial_template_engine, :erb
  enable :partial_underscores
end


configure :development do
end

configure :test do
  disable :logging
end

configure :production do
end
