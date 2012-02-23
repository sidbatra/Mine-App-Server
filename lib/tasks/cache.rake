namespace :cache do

  desc "Clear rails cache"
  task :clear => :environment do |e,args|
    Cache.clear
  end

end #cache
