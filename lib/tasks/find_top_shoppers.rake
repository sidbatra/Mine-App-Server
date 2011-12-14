desc "Find top shoppers for popular stores"

task :find_top_shoppers do |e,args|
  
  require 'config/environment.rb'
 
    Store.processed.each do |store|

      old_shoppers    = AchievementSet.top_shoppers(store.id).map(&:achievable).map(&:id)
      new_shoppers    = User.top_shoppers(store.id)

      AchievementSet.add_top_shoppers(store.id,new_shoppers)

      users_to_email  = new_shoppers.reject{|u| old_shoppers.include?(u.id)}
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
