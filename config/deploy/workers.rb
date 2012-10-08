Capistrano::Configuration.instance(:must_exist).load do

  namespace :workers do
    
    desc "Start workers on the worker server"
    task :start, :roles => :worker do
      run "cd #{current_path} && "\
          "nohup bash script/workers start #{total_workers} #{environment}", :pty => true
    end

    desc "Restart workers on the worker server"
    task :restart, :roles => :worker do
      run "cd #{current_path} && "\
          "nohup bash script/workers restart #{total_workers} #{environment}", :pty => true
    end

    desc "Stop workers on the worker server"
    task :stop, :roles => :worker do
      run "cd #{current_path} && "\
          "nohup bash script/workers stop #{total_workers} #{environment}", :pty => true
    end

  end

end
