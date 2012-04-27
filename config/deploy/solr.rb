Capistrano::Configuration.instance(:must_exist).load do

  namespace :solr do 
    
    desc "Install folders for solr"
    task :install, :roles => :search do
      run "cp -r #{current_path}/solr #{shared_path}"
    end
    
    desc "Start the solr daemon"
    task :start, :roles => :search do
      rake "sunspot:solr:start"
    end
    
    desc "Stop the solr daemon"
    task :stop, :roles => :search do
      rake "sunspot:solr:stop"
    end
    
    desc "Restart the solr daemon"
    task :restart, :roles => :search do
      stop
      start
    end

    desc "Regenerate the index"
    task :index do
      rake "sunspot:solr:index", :local => true
    end
  end

end
