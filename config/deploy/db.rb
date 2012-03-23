Capistrano::Configuration.instance(:must_exist).load do

  namespace :db do 

    desc "Create link to database.yml for the deploy environment"
    task :config do
      run "ln -s "\
          "#{current_path}/config/database/#{environment}.yml "\
          "#{current_path}/config/database.yml"
    end

    desc "Run migrations on the datbase for the deploy environment"
    task :migrate do
      rake "db:migrate",{:local => true}
    end

  end
end

