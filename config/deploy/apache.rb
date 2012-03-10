Capistrano::Configuration.instance(:must_exist).load do

  namespace :apache do

    desc "Install the apache virtual host configuration file"
    task :config, :roles => :web do
      run "cd #{current_path} && "\
          "sudo cp config/apache/#{environment} "\
          "/etc/apache2/sites-available/#{application}"
      run "sudo a2ensite #{application}"
    end

    desc "Start the apache server for the first time"
    task :start, :roles => :web do
      run "sudo /etc/init.d/apache2 start"
    end

    desc "Restart the apache server"
    task :restart, :roles => :web do
      run "sudo /etc/init.d/apache2 restart"
    end

  end

end

