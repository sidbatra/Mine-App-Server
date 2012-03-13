Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do

    desc "Deploy codebase onto an empty server"
    task :install do 
      permissions.remote

      deploy.setup
      deploy.update

      permissions.setup

      db.config

      gems.install

      if servers? :web
        apache.config
        apache.start
      end

      if servers? :worker
        workers.start
      end

      logrotate.install

      if servers? :web or servers? :worker
        cron.update_web_proc
      end

      if servers? :cron
        cron.update_cron
      end

      if servers? :web
        monit.config_web
      end

      if servers? :worker
        monit.config_worker
      end

      monit.restart
    end
     
    desc "Deploy delta codebase update onto a pre-deployed server"
    task :release do 
      assets.remote

      deploy.update

      db.config

      gems.install

      db.migrate

      
      if servers? :web
        passenger.restart
      end

      
      if servers? :worker
        workers.restart
      end

      cache.clear

      if servers? :web or servers? :worker
        cron.update_web_proc
      end

      if servers? :cron
        cron.update_cron
      end

      if servers? :web
        monit.config_web
      end

      if servers? :worker
        monit.config_worker
      end

      monit.restart
    end

  end

end
