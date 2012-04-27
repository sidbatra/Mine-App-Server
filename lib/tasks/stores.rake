namespace :stores do

  namespace :update do

    desc "Update domains for each store"
    task :domains => :environment do |e,args|
    begin

      Store.approved.each do |store|
          ProcessingQueue.push(store,:update_domain)
      end

    rescue => ex
      puts "Critical error while updating store domains"
      LoggedException.add(__FILE__,__method__,ex)
    end
    end #domains


    desc "Update metadata for each store"
    task :metadata => :environment do |e,args|
    begin

      Store.approved.each do |store|
          ProcessingQueue.push(store,:update_metadata)
      end

    rescue => ex
      puts "Critical error while updating store metadata"
      LoggedException.add(__FILE__,__method__,ex)
    end
    end #domains

  end #update
end #stores
