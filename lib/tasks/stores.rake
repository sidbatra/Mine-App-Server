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


  namespace :dump do
    
    desc "Dump two text files containing crawlable stores"
    task :crawlable => :environment do |e,args|
    begin
      stores = Store.crawlable.with_crawl_datum

      url_file = File.open(File.join(RAILS_ROOT,"urls.txt"),"w")
      hash_file = File.open(File.join(RAILS_ROOT,"hash.txt"),"w")

      stores.each do |store|
        url_file.puts "#{store.crawl_datum.launch_url}\tnutch.score=20"
        hash_file.puts ({ 
                        :id => store.id, 
                        :domain => store.domain, 
                        :use_og_image => store.crawl_datum.use_og_image
                        }.to_json.to_s)
      end

      url_file.close
      hash_file.close

    rescue => ex
      puts "Critical error while dumping crawlable stores"
      LoggedException.add(__FILE__,__method__,ex)
    end
    end
  end #dump

end #stores
