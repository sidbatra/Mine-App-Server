Capistrano::Configuration.instance(:must_exist).load do

  namespace :logrotate do
    
    desc "Install logrotate config"
    task :install, :roles => [:web,:worker,:cron] do
      run "sudo cp #{current_path}/config/logrotate/rails /etc/logrotate.d"
      run "sudo chown root:root /etc/logrotate.d/rails"
      run "sudo chmod 644 /etc/logrotate.d/rails"
    end
  end

end

