require 'config/deploy/staging'
require 'config/deploy/production'
require 'config/deploy/helpers'
require 'config/deploy/deploy'
require 'config/deploy/db'
require 'config/deploy/sphinx'
require 'config/deploy/passenger'
require 'config/deploy/apache'
require 'config/deploy/monit'
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


namespace :logrotate do
  
  desc 'Install logrotate config'
  task :install, :roles => [:web,:worker,:cron] do
    run "sudo cp #{current_path}/config/logrotate/rails /etc/logrotate.d"
    run "sudo chown root:root /etc/logrotate.d/rails"
    run "sudo chmod 644 /etc/logrotate.d/rails"
  end
end


namespace :cache do

  desc 'Clear the cache'
  task :clear do
    system "cd #{Dir.pwd} && "\
            "rake cache:clear RAILS_ENV=#{environment}"
  end

end


namespace :workers do
  
  desc 'Start workers on the worker server'
  task :start, :roles => :worker do
    run "cd #{current_path} && "\
        "bash script/workers start #{total_workers} #{environment}"
  end

  desc 'Restart workers on the worker server'
  task :restart, :roles => :worker do
    run "cd #{current_path} && "\
        "bash script/workers restart #{total_workers} #{environment}"
  end

  desc 'Stop workers on the worker server'
  task :stop, :roles => :worker do
    run "cd #{current_path} && "\
        "bash script/workers stop #{total_workers} #{environment}"
  end

end


namespace :gems do

  desc 'Install required gems on the web and worker servers'
  task :install, :roles => [:web,:worker,:cron] do
    run "cd #{current_path} && sudo rake gems:install RAILS_ENV=#{environment}" 
  end

end


namespace :assets do

  desc 'Install remote assets on to S3'
  task :remote do

    system "cd #{Dir.pwd} && RAILS_ENV=#{environment} "\
            "rake assets:deploy" 
  end

end


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

