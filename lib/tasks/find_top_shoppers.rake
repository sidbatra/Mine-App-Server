desc "Find top shoppers for popular stores"

task :find_top_shoppers do |e,args|
  
  require 'config/environment.rb'
 
    Store.processed.popular.limit(20).each do |store|
      key = "views/#{KEYS[:store_top_shoppers] % store.id}"

      cached_json   = Cache.fetch(key)
      old_shoppers  = cached_json ? JSON.parse(cached_json).map{|u| u['id']} : []

      Cache.delete(key)

      users_to_email = User.top_shoppers(store.id).reject{|u| old_shoppers.include?(u.id)}
      puts store.name

      users_to_email.each do |user|
        begin 
          UserMailer.deliver_top_shopper(user,store)    
          puts user.handle
          sleep 2
        rescue => ex
          puts "exception for #{user.handle}"
          LoggedException.add(__FILE__,__method__,ex)    
        end#begin
      end#user
    end#store

end
