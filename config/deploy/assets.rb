Capistrano::Configuration.instance(:must_exist).load do

  namespace :assets do

    desc "Package and deploy assets to asset host"
    task :remote do
      rake "assets:deploy", :local => true
    end

  end

end

