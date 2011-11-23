desc "Find star users"

task :find_star_users do |e,args|
  
  require 'config/environment.rb'
  
  Rails.cache.delete(KEYS[:star_users])
  users = User.stars

  users.each do |user|
    begin
      UserMailer.decide_star_user(user)    
      sleep 2
    rescue => ex
      LoggedException.add(__FILE__,__method__,ex)    
    end#begin
  end#user

end
