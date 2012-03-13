Capistrano::Configuration.instance(:must_exist).load do

  namespace :permissions do

    desc "Setup remote permissions for ssh"
    task :remote do
      run "rm .ssh/known_hosts"
    end
    
    desc "Setup proper permissions for new files"
    task :setup, :roles => [:web,:worker,:cron] do
      run "sudo touch #{current_path}/log/#{environment}.log"
      run "sudo chown -R manager:manager #{current_path}/log/#{environment}.log"
    end

  end

end

