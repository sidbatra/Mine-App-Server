Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do

    desc "Deploy codebase onto an empty server"
    task :install do 
      #assets.remote

      permissions.remote

      deploy.setup
      deploy.update

      permissions.setup

      db.config

      gems.install

      #db.migrate

      apache.config
      apache.start

      workers.start

      logrotate.install
      cron.update_web_proc
      cron.update_cron

      monit.config_web
      monit.config_worker
      monit.restart
    end
     
    desc "Deploy delta codebase update onto a pre-deployed server"
    task :release do 
      assets.remote

      deploy.update

      db.config

      gems.install

      db.migrate

      passenger.restart
      workers.restart

      cache.clear

      cron.update_web_proc
      cron.update_cron

      monit.config_web
      monit.config_worker
      monit.restart
    end

  end

end
