desc "Find star users"

task :find_star_users do |e,args|
  
  require 'config/environment.rb'

  old_stars       = AchievementSet.star_users.map(&:achievable).map(&:id)
  new_stars       = User.stars

  AchievementSet.add_star_users(new_stars)

  users_to_email  = new_stars.reject{|u| old_stars.include?(u.id)}

  users_to_email.each do |user|
    begin
      UserMailer.deliver_star_user(user)    
      puts user.handle
      sleep 2
    rescue => ex
      puts "exception for #{user.handle}"
      LoggedException.add(__FILE__,__method__,ex)    
    end#begin
  end#user

end
