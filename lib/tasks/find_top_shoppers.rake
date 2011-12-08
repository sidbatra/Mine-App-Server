desc "Find top shoppers for popular stores"

task :find_top_shoppers do |e,args|
  
  require 'config/environment.rb'
 
    Store.top.each do |store|
      old_shoppers    = User.top_shoppers(store.id)

      # TODO: The cache key :store_top_shopper has been deprecated
      Rails.cache.delete(KEYS[:store_top_shoppers] % store.id)

      new_shoppers    = User.top_shoppers(store.id)
      users_to_email  = new_shoppers - old_shoppers
      
      users_to_email.each do |user|
        begin 
          UserMailer.decide_top_shopper(user,store)    
          sleep 2
        rescue => ex
          LoggedException.add(__FILE__,__method__,ex)    
        end#begin
      end#user
    end#store

end
