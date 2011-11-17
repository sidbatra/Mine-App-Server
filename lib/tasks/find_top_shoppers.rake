desc "Find top shoppers for popular stores"

task :find_top_shoppers do |e,args|
  
  require 'config/environment.rb'
 
  Store.top.each do |store|
    Rails.cache.delete(KEYS[:store_top_shoppers] % store.id)
    users = User.top_shoppers(store.id)

    users.each do |user|
      #UserMailer.deliver_top_shopper(user,store)    
    end
  end

end
