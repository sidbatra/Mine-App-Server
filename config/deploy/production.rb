Capistrano::Configuration.instance(:must_exist).load do

  desc "Setup configuration variables for deploying in a "\
        "production environment"
  task :production do

    # Population of roles requires setting up of environment
    # variables for the different roles. The expected syntax
    # is a simple csv.
    #
    role(:web)          { ENV['web_servers'].split(',') }
    role(:worker)       { ENV['proc_servers'].split(',') }
    role(:cron)         { ENV['cron_servers'].split(',') }
    role(:search)       { ENV['search_servers'].split(',') }
    
    # Total processing queue worker instances on proc servers
    #
    set :total_workers, 4
    set :environment, "production"
    set :branch, "master"
  end

end
