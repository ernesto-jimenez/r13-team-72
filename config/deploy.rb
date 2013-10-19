require 'bundler/capistrano'

# This capistrano deployment recipe is made to work with the optional
# StackScript provided to all Rails Rumble teams in their Linode dashboard.
#
# After setting up your Linode with the provided StackScript, configuring
# your Rails app to use your GitHub repository, and copying your deploy
# key from your server's ~/.ssh/github-deploy-key.pub to your GitHub
# repository's Admin / Deploy Keys section, you can configure your Rails
# app to use this deployment recipe by doing the following:
#
# 1. Add `gem 'capistrano', '~> 2.15'` to your Gemfile.
# 2. Run `bundle install --binstubs --path=vendor/bundles`.
# 3. Run `bin/capify .` in your app's root directory.
# 4. Replace your new config/deploy.rb with this file's contents.
# 5. Configure the two parameters in the Configuration section below.
# 6. Run `git commit -a -m "Configured capistrano deployments."`.
# 7. Run `git push origin master`.
# 8. Run `bin/cap deploy:setup`.
# 9. Run `bin/cap deploy:migrations` or `bin/cap deploy`.
#
# Note: You may also need to add your local system's public key to
# your GitHub repository's Admin / Deploy Keys area.
#
# Note: When deploying, you'll be asked to enter your server's root
# password. To configure password-less deployments, see below.

#############################################
##                                         ##
##              Configuration              ##
##                                         ##
#############################################

GITHUB_REPOSITORY_NAME = 'r13-team-72'
LINODE_SERVER_HOSTNAME = 'rubykaizen.com'
WORKER_COUNT = 1

#############################################
#############################################

# General Options

set :bundle_flags,               "--deployment"

set :application,                "railsrumble"
set :deploy_to,                  "/var/www/apps/railsrumble"
set :normalize_asset_timestamps, false
set :rails_env,                  "production"

set :user,                       "root"
set :runner,                     "www-data"
set :admin_runner,               "www-data"

# Password-less Deploys (Optional)
#
# 1. Locate your local public SSH key file. (Usually ~/.ssh/id_rsa.pub)
# 2. Execute the following locally: (You'll need your Linode server's root password.)
#
#    cat ~/.ssh/id_rsa.pub | ssh root@LINODE_SERVER_HOSTNAME "cat >> ~/.ssh/authorized_keys"
#
# 3. Uncomment the below ssh_options[:keys] line in this file.
#
# ssh_options[:keys] = ["~/.ssh/id_rsa"]

# SCM Options
set :scm,        :git
set :repository, "git@github.com:railsrumble/#{GITHUB_REPOSITORY_NAME}.git"
set :branch,     "master"

# Roles
role :app, LINODE_SERVER_HOSTNAME
role :db,  LINODE_SERVER_HOSTNAME, :primary => true
role :resque_worker, LINODE_SERVER_HOSTNAME
role :resque_scheduler, LINODE_SERVER_HOSTNAME

# Add Configuration Files & Compile Assets
after 'deploy:update_code' do
  # Setup Configuration
  run "cp #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"

  # Link shared/repos
  run "ln -s #{shared_path}/repos #{release_path}/repos"

  # Compile Assets
  #run "cd #{release_path}; RACK_ENV=production bundle exec rake assets:precompile"
end

# Restart Passenger
deploy.task :restart, :roles => :app do
  # Fix Permissions
  sudo "chown -R www-data:www-data #{current_path}"
  sudo "chown -R www-data:www-data #{latest_release}"
  sudo "chown -R www-data:www-data #{shared_path}/repos"
  sudo "chown -R www-data:www-data #{shared_path}/bundle"
  sudo "chown -R www-data:www-data #{shared_path}/log"

  # Restart Application
  run "touch #{current_path}/tmp/restart.txt"
end

desc "Hot-reload God configuration for the Resque worker"
deploy.task :reload_god_config do
  sudo "god stop resque"
  sudo "god load #{File.join deploy_to, 'current', 'config', 'resque.god'}"
  sudo "god start resque"
end

after :deploy, 'deploy:reload_god_config'

desc "Start resque workers"
deploy.task :workers_start, :roles => :resque_worker do
  # Start n workers with separate run commands, so we can store their PIDs
  1.upto(WORKER_COUNT) do |i|
    run "#{sudo as: 'www-data'} /bin/sh -c 'if [ ! -e #{deploy_to}/shared/pids/resque_production_#{i}.pid ]; then cd #{deploy_to}/current && RACK_ENV=production QUEUE=* PIDFILE=#{deploy_to}/shared/pids/resque_production_#{i}.pid BACKGROUND=yes bundle exec rake resque:work; fi;'"
  end
end

desc "Stop resque workers"
deploy.task :workers_stop, :roles => :resque_worker do
  1.upto(WORKER_COUNT) do |i|
    run "if [ -e #{deploy_to}/shared/pids/resque_production_#{i}.pid ]; then echo \"Killing Worker #1\"; kill -s QUIT `cat #{deploy_to}/shared/pids/resque_production_#{i}.pid`; rm -f #{deploy_to}/shared/pids/resque_production_#{i}.pid; echo \"Done\"; fi;"
  end
end

