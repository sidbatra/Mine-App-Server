
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



task :staging do 
  role(:web)          { ENV['web_servers'].split(',') }
  role(:worker)       { ENV['proc_servers'].split(',') }
  role(:cron)         { ENV['cron_servers'].split(',') }
  #role :search,       "ec2-174-129-148-194.compute-1.amazonaws.com",
  #                      :no_release => true
  set :total_workers, 3
  set :environment,   "staging"
  set :branch,        "develop"
end


task :production do
  role(:web)          { ENV['web_servers'].split(',') }
  role(:worker)       { ENV['proc_servers'].split(',') }
  role(:cron)         { ENV['cron_servers'].split(',') }
  #role :search,       "ec2-107-22-94-58.compute-1.amazonaws.com",
  #                      :no_release => true
  set :total_workers, 3
  set :environment,   "production"
  set :branch,        "master"
end

namespace :deploy do

  desc 'Setup the servers for a first time release' 
  task :install do 
    system "cap #{environment}  assets:remote"

    system "cap #{environment}  permissions:remote"

    system "cap #{environment}  deploy:setup"
    system "cap #{environment}  deploy:update"

    #system "cap #{environment}  misc:directories"

    system "cap #{environment}  permissions:setup"

    system "cap #{environment}  db:config" 

    system "cap #{environment}  gems:install"


    if environment == "staging"
      #system "cap #{environment}  db:populate" 
      #system "cap #{environment}  db:migrate"
    else
      system "cap #{environment}  db:migrate"
    end


    system "cap #{environment}  apache:config"
    system "cap #{environment}  apache:start"
    #system "cap #{environment}  search:start"

    system "cap #{environment}  workers:start"

    system "cap #{environment}  logrotate:install"
    system "cap #{environment}  cron:update_web_proc"
    system "cap #{environment}  cron:update_cron"

    system "cap #{environment} monit:config_web"
    system "cap #{environment} monit:config_worker"
    system "cap #{environment} monit:restart"
  end

   
  desc 'A delta release across all the servers'
  task :release do 
    system "cap #{environment}  assets:remote"

    system "cap #{environment}  deploy:update"

    system "cap #{environment}  db:config" 

    system "cap #{environment}  gems:install"

    system "cap #{environment}  db:migrate"

    system "cap #{environment}  passenger:restart"
    system "cap #{environment}  workers:restart"

    #system "cap #{environment}  search:index"
    system "cap #{environment}  cache:clear"

    system "cap #{environment}  cron:update_web_proc"
    system "cap #{environment}  cron:update_cron"

    system "cap #{environment} monit:config_web"
    system "cap #{environment} monit:config_worker"
    system "cap #{environment} monit:restart"

    system "cap #{environment} brant:migrate"
  end

end


namespace :db do 

  desc 'Setup database.yml'
  task :config, :role => [:web,:worker,:cron] do
    run "ln -s "\
        "#{current_path}/config/database/#{environment}.yml "\
        "#{current_path}/config/database.yml"
  end

  desc 'Create database, load scehma and populate database from sql dump'
  task :populate do
    run "cd #{current_path} && rake db:create RAILS_ENV=#{environment}"
    run "cd #{current_path} && rake db:schema:load RAILS_ENV=#{environment}"
  end

  desc 'Run a migration'
  task :migrate do
    system "cd #{Dir.pwd} && "\
        "rake db:migrate RAILS_ENV=#{environment}" 
  end

end

namespace :brant do

  desc 'Run a brant migration'
  task :migrate do
    system "cd #{Dir.pwd} && "\
        "rake brant:migrate RAILS_ENV=#{environment}" 
  end
end

namespace :search do 
  
  desc 'Start the sphinx machines'
  task :start, :roles => :search do
    run "cd #{current_path} && rake ts:index RAILS_ENV=#{environment}"
    run "cd #{current_path} && rake ts:start RAILS_ENV=#{environment}"
  end

  desc 'Reindex the sphinx machines'
  task :index, :roles => :search do
    run "cd #{current_path} && rake ts:index RAILS_ENV=#{environment}"
  end
end


namespace :passenger do

  desc 'Restart passenger by touching restart.txt'
  task :restart, :roles => :web, :except => {:no_release => true} do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

end


namespace :apache do

  desc 'Install the apache virtual host configuration file'
  task :config, :roles => :web do
    run "cd #{current_path} && "\
        "sudo cp config/apache/#{environment} "\
        "/etc/apache2/sites-available/#{application}"
    run "sudo a2ensite #{application}"
  end

  desc 'Start the apache server for the first time'
  task :start, :roles => :web do
    run "sudo /etc/init.d/apache2 start"
  end

  desc 'Restart the apache server'
  task :restart, :roles => :web do
    run "sudo /etc/init.d/apache2 restart"
  end

end


namespace :monit do
  
  desc 'Install the monit configuration file for web servers'
  task :config_web, :roles => :web do
    run "sudo cp #{current_path}/config/monit/#{environment}_web /etc/monit.d/"
  end

  
  desc 'Install the monit configuration file for proc servers'
  task :config_worker, :roles => :worker do
    run "sudo cp #{current_path}/config/monit/#{environment}_proc /etc/monit.d/"
  end

  desc 'Start the monit daemon'
  task :start, :roles => [:web,:worker] do
    run "sudo /etc/init.d/monit start"
  end

  desc 'Restart the monit daemon'
  task :restart, :roles => [:web,:worker] do
    run "sudo /etc/init.d/monit restart"
  end

  desc 'Stop the monit daemon'
  task :stop, :roles => [:web,:worker] do
    run "sudo /etc/init.d/monit stop"
  end
end

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

  desc 'Install local assets on the web and worker servers'
  task :local, :roles => [:web,:worker] do
  end

  desc 'Install remote assets on to S3'
  task :remote do

    system "cd #{Dir.pwd} && RAILS_ENV=#{environment} "\
            "rake upload_resources_to_assethost" 

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

namespace :misc do

  desc 'Setup the diretory structure of the release directory'
  task :directories do
    run "mkdir #{shared_path}/sphinx"
  end

end


