Capistrano::Configuration.instance(:must_exist).load do

  namespace :passenger do

    desc "Restart passenger instances"
    task :restart, :roles => :web do
       run "sudo touch #{File.join(current_path,'tmp','restart.txt')}"
    end

  end

end

