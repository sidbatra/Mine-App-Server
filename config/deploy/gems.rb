Capistrano::Configuration.instance(:must_exist).load do

  namespace :gems do

    desc "Install missing gems"
    task :install do
      rake "gems:install",:sudo => true
    end

  end

end

