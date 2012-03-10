require 'config/deploy/staging'
require 'config/deploy/production'
require 'config/deploy/helpers'
require 'config/deploy/deploy'
require 'config/deploy/db'
require 'config/deploy/sphinx'
require 'config/deploy/passenger'
require 'config/deploy/apache'
require 'config/deploy/monit'
require 'config/deploy/logrotate'
require 'config/deploy/cache'
require 'config/deploy/workers'
require 'config/deploy/gems'
require 'config/deploy/assets'
require 'config/deploy/gum'


set :application,   "closet"

set :scm,           :git
set :repository,    "git@github.com:Denwen/Hasit-App-Server.git"
set :user,          "manager"  
set :deploy_via,    :remote_cache

set :deploy_to,     "/vol/#{application}"
set :use_sudo,      false

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = false












namespace :permissions do

  desc 'Setup remote permissions for ssh'
  task :remote do
    run "rm .ssh/known_hosts"
  end
  
  desc 'Setup proper permissions for new files'
  task :setup, :roles => [:web,:worker,:cron] do
    run "sudo touch #{current_path}/log/#{environment}.log"
    run "sudo chown -R manager:manager #{current_path}/log/#{environment}.log"
  end

end


namespace :cron do
  
  desc 'Update cron on web and proc servers'
  task :update_web_proc, :roles => [:web,:worker] do
    run "cd #{current_path} && RAILS_ENV=#{environment} "\
        "whenever -w -f config/whenever/web_proc.rb"
  end

  desc 'Update cron on cron servers'
  task :update_cron, :roles => [:cron] do
    run "cd #{current_path} && RAILS_ENV=#{environment} "\
        "whenever -w -f config/whenever/cron.rb"
  end

end

