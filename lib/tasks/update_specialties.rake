desc "Update specialties for top stores"

task :update_specialties do |e,args|

  require 'config/environment.rb'

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

end
