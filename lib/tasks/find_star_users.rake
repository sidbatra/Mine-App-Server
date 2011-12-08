desc "Find star users"

task :find_star_users do |e,args|
  
  require 'config/environment.rb'
  
  old_stars = User.stars

  ##TODO: Deprecated. KEYS[:star_users] no longer contains
  # User model objects. Instead it contains a json array of
  # the same User models.
  #
  Rails.cache.delete(KEYS[:star_users])

  new_stars       = User.stars
  users_to_email  = new_stars - old_stars

  users_to_email.each do |user|
    puts user.handle
    begin
      UserMailer.decide_star_user(user)    
      sleep 2
    rescue => ex
      LoggedException.add(__FILE__,__method__,ex)    
    end#begin
  end#user

end
