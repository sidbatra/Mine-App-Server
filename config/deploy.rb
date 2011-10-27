
set :application,   "felvy"

set :scm,           :git
set :repository,    "git@github.com:Denwen/Hasit-App-Server.git"
set :user,          "manager"  
set :deploy_via,    :remote_cache

set :deploy_to,     "/vol/#{application}"
set :use_sudo,      false

set :db_dump,       "private/denwen_production_1305869864.sql"

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true



task :staging do 
  role :web,          "ec2-107-20-229-8.compute-1.amazonaws.com"
  role :worker,       "ec2-107-20-229-8.compute-1.amazonaws.com"
  role :db,           "ec2-107-20-229-8.compute-1.amazonaws.com", 
                        :no_release => true
  role :search,       "ec2-107-20-229-8.compute-1.amazonaws.com", 
                        :no_release => true
  role :cache,        "ec2-107-20-229-8.compute-1.amazonaws.com", 
                        :no_release => true
  set :total_workers, 1
  set :environment,   "staging"
  set :branch,        "master"
  set :apnd_file,     "apns-dev.pem"
  set :apnd_host,     "gateway.sandbox.push.apple.com"
end


task :production do
  role :web,          "ec2-75-101-204-136.compute-1.amazonaws.com","ec2-67-202-63-102.compute-1.amazonaws.com"
  role :worker,       "ec2-107-22-21-214.compute-1.amazonaws.com"
  role :db,           "ec2-75-101-204-136.compute-1.amazonaws.com",
                        :no_release => true
  role :search,       "ec2-75-101-204-136.compute-1.amazonaws.com",
                        :no_release => true
  role :cache,        "ec2-75-101-204-136.compute-1.amazonaws.com",
                        :no_release => true
  set :total_workers, 3
  set :environment,   "production"
  set :branch,        "master"
  set :apnd_file,     "apple_push_notification_production.pem"
  set :apnd_host,     "gateway.push.apple.com"
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

    system "cap #{environment}  gems:install"


    if environment == "staging"
      #system "cap #{environment}  db:config" 
      #system "cap #{environment}  db:populate" 
      run "cd #{current_path} && RAILS_ENV=#{environment} rake db:reset"
      #system "cap #{environment}  db:migrate"
    else
      system "cap #{environment}  db:migrate"
    end


    system "cap #{environment}  apache:config"
    system "cap #{environment}  apache:start"
    #system "cap #{environment}  search:start"
    #system "cap #{environment}  cache:start"

    system "cap #{environment}  workers:start"

    #system "cap #{environment}  misc:apnd"
    #system "cap #{environment}  misc:whenever"

  end

   
  desc 'A delta release across all the servers'
  task :release do 
    system "cap #{environment}  assets:remote"

    system "cap #{environment}  deploy:update"

    system "cap #{environment}  gems:install"

    if environment == "staging"
      #system "cap #{environment}  db:config" 
    end

    system "cap #{environment}  db:migrate"

    system "cap #{environment}  passenger:restart"
    system "cap #{environment}  workers:restart"

    #system "cap #{environment}  search:index"

    #system "cap #{environment}  misc:whenever"
  end

end


namespace :db do 

  desc 'Setup database.yml'
  task :config, :role => :db do
    run "cd #{current_path} && "\
        "sed -i -e "\
        "'s/denwen_#{environment}/denwen_#{environment}_#{deploy_name}/g' "\
        "config/database.yml"
  end

  desc 'Create database, load scehma and populate database from sql dump'
  task :populate, :roles => :db do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake db:create"
    run "cd #{current_path} && RAILS_ENV=#{environment} rake db:schema:load"
    run "cd #{current_path} && "\
        "RAILS_ENV=#{environment} "\
        "rake load_db_from_dump[#{db_dump},#{deploy_name}]"
  end

  desc 'Run a migration'
  task :migrate do
    system "cd #{Dir.pwd} && "\
        "RAILS_ENV=#{environment} rake db:migrate" 
  end

end

namespace :search do 
  
  desc 'Start the sphinx machines'
  task :start, :roles => :search do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake ts:index"
    run "cd #{current_path} && RAILS_ENV=#{environment} rake ts:start"
  end

  desc 'Reindex the sphinx machines'
  task :index, :roles => :search do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake ts:index"
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
        "/etc/apache2/sites-available/felvy"
    run "sudo a2ensite felvy"
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


namespace :cache do
  
  desc 'Start the memcached daemon on the cache server'
  task :start, :roles => :cache do
    run "memcached -d -m 450 -t 6"
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
  task :install, :roles => [:web,:worker] do
    run "cd #{current_path} && RAILS_ENV=#{environment} sudo rake gems:install" 
  end

end


namespace :assets do

  desc 'Install local assets on the web and worker servers'
  task :local, :roles => [:web,:worker] do
  end

  desc 'Install remote assets on to S3'
  task :remote do

    system "cd #{Dir.pwd} && RAILS_ENV=#{environment} "\
            "rake rename_resources_for_deployment[#{current_revision}]" 

    system "cd #{Dir.pwd} && RAILS_ENV=#{environment} "\
            "rake asset:packager:build_all"
    
    #system "gzip public/javascripts/application_packaged.js"
    #system "mv public/javascripts/application_packaged.js.gz public/javascripts/application_packaged.js"
    #system "gzip public/stylesheets/application_packaged.css"
    #system "mv public/stylesheets/application_packaged.css.gz public/stylesheets/application_packaged.css"

    system "cd #{Dir.pwd} && RAILS_ENV=#{environment} "\
            "rake upload_resources_to_assethost[#{current_revision}]" 

    system "cd #{Dir.pwd} && "\
            "RAILS_ENV=#{environment} rake asset:packager:delete_all"

    system "git checkout ."
  end

end


namespace :permissions do

  desc 'Setup remote permissions for ssh'
  task :remote do
    run "rm .ssh/known_hosts"
  end
  
  desc 'Setup proper permissions for new files'
  task :setup, :roles => [:web,:worker] do
    run "sudo touch #{current_path}/log/#{environment}.log"
    run "sudo chown -R manager:svn #{current_path}/log/#{environment}.log"
  end

end

namespace :misc do
  
  desc 'Turn on apnd for sending push notifications'
  task :apnd, :roles => :worker do
    run "sudo apnd "\
        "--apple-cert #{current_path}/config/#{apnd_file} "\
        "--daemon-timer 2 --daemon-bind localhost "\
        "--apple-host #{apnd_host} && sleep 3"
  end

  task :whenever, :roles => :worker do
    run "cd #{current_path} && RAILS_ENV=#{environment} whenever -w"
  end

  desc 'Setup the diretory structure of the release directory'
  task :directories do
    run "mkdir #{shared_path}/sphinx"
  end

end


