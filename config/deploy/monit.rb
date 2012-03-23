Capistrano::Configuration.instance(:must_exist).load do

  namespace :monit do
    
    desc "Install the monit configuration file for web servers"
    task :config_web, :roles => :web do
      run "sudo cp #{current_path}/config/monit/#{environment}_web "\
          "/etc/monit.d/"
    end

    desc "Install the monit configuration file for proc servers"
    task :config_worker, :roles => :worker do
      run "sudo cp #{current_path}/config/monit/#{environment}_proc "\
          "/etc/monit.d/"
    end

    desc "Install the monit configuration file for search servers"
    task :config_search, :roles => :search do
      run "sudo cp #{current_path}/config/monit/#{environment}_search "\
          "/etc/monit.d/"
    end

    desc "Start the monit daemon"
    task :start, :roles => [:web,:worker] do
      run "sudo /etc/init.d/monit start"
    end

    desc "Restart the monit daemon"
    task :restart, :roles => [:web,:worker] do
      run "sudo /etc/init.d/monit restart"
    end

    desc "Stop the monit daemon"
    task :stop, :roles => [:web,:worker] do
      run "sudo /etc/init.d/monit stop"
    end

  end

end

