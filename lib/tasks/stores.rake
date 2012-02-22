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


    desc "Update specialties for top stores"
    task :specialties => :environment do |e,args|

      Store.processed.with_products.each do |store|
        hash = Hash.new(0)

        store.products.each do |product|
          hash[product.category_id] += 1
        end

        hash.sort{|a,b| b[1] <=> a[1]}.each_with_index do |(k,v),i|
          Specialty.add(
            store.id,
            k,
            ((v*100.0)/store.products_count).round,
            i==0)
        end
      end

    end #specialties

  end #update
end #stores
