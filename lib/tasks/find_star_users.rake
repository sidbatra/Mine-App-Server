desc "Find star users"

task :find_star_users do |e,args|
  
  require 'config/environment.rb'
  
  begin 
    Rails.cache.delete(KEYS[:star_users])
    users = User.stars

    users.each do |user|
      UserMailer.decide_star_user(user)    
      sleep 2
    end
  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)    
  end

end
