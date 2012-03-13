Capistrano::Configuration.instance(:must_exist).load do

  namespace :cache do

    desc "Clear the cache"
    task :clear do
      rake "cache:clear",:local => true
    end

  end

end

