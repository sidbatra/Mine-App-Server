desc "Find top shoppers for popular stores"

task :find_top_shoppers do |e,args|
  
  require 'config/environment.rb'
 
  begin 
    Store.top.each do |store|
      Rails.cache.delete(KEYS[:store_top_shoppers] % store.id)
      users = User.top_shoppers(store.id)

      users.each do |user|
        UserMailer.decide_top_shopper(user,store)    
        sleep 2
      end
    end
  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)    
  end

end
