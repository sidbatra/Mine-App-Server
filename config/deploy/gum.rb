Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do


    desc "TESTING IT OUT"
    task :gum,:roles => [:web,:worker] do
      run "ls"
      rake "gems:install",{:sudo => true}
    end

    task :proxy do
      deploy.gum
    end
  end
end
