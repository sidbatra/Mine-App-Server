namespace :update do

  desc "Update star users"
  task :star_users do |e,args|
    
    require 'config/environment.rb'

    old_stars       = AchievementSet.current_star_users.
                          map(&:achievable).
                          map(&:id)

    new_stars       = User.stars.limit(20)

    AchievementSet.add(
      AchievementSetOwner::Automated,
      AchievementSetFor::StarUsers,
      new_stars,
      new_stars.map(&:id))

    users_to_email  = new_stars.reject{|u| old_stars.include?(u.id)}

    users_to_email.each do |user|
      begin
        UserMailer.deliver_star_user(user)    
        puts user.handle
        sleep 0.25
      rescue => ex
        puts "exception for #{user.handle}"
        LoggedException.add(__FILE__,__method__,ex)    
      end#begin
    end#user
  end#star_users


  desc "Update top shoppers for popular stores"
  task :top_shoppers do |e,args|
    
    require 'config/environment.rb'
   
      Store.processed.popular.each do |store|
        begin
          old_shoppers = AchievementSet.current_top_shoppers(store.id).
                          map(&:achievable).
                          map(&:id)
          new_shoppers = User.top_shoppers(store.id).limit(20)

          AchievementSet.add(
            store.id,
            AchievementSetFor::TopShoppers,
            new_shoppers,
            new_shoppers.map(&:id))

          users_to_email  = new_shoppers.reject{|u| old_shoppers.include?(u.id)}
          puts store.name

          users_to_email.each do |user|
            begin 
              UserMailer.deliver_top_shopper(user,store)    
              puts user.handle
              sleep 0.25
            rescue => ex
              puts "exception for #{user.handle}"
              LoggedException.add(__FILE__,__method__,ex)    
            end#begin_user
          end#user

        rescue => ex
          puts "#{ex.to_s} for #{store.name}"
          LoggedException.add(__FILE__,__method__,ex)    
        end#begin_store

      end#store
  end#top_shoppers

end#namespace
