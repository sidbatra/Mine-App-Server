desc "Find star users"

task :find_star_users do |e,args|
  
  require 'config/environment.rb'

  key = "views/#{KEYS[:star_users]}"
  
  cached_json     = Cache.fetch(key)
  old_stars       = cached_json ? JSON.parse(cached_json).map{|u| u['id']} : []

  Cache.delete(key)

  users_to_email  = User.stars.reject{|u| old_stars.include?(u.id)}

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
