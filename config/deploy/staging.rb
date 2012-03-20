
# Hardcode environment variables representing roles for debugging
#
#ENV['web_servers'] = "ec2-23-20-139-220.compute-1.amazonaws.com"
#ENV['proc_servers'] = "ec2-107-21-161-38.compute-1.amazonaws.com"
#ENV['cron_servers'] = "ec2-107-20-40-7.compute-1.amazonaws.com"


Capistrano::Configuration.instance(:must_exist).load do

  desc "Setup configuration variables for deploying in a "\
        "production environment"
  task :staging do 

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
    set :total_workers, 3
    set :environment,   "staging"
    set :branch,        "develop"
  end
end
