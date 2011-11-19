desc "Find star users"

task :find_star_users do |e,args|
  
  require 'config/environment.rb'
  
  Rails.cache.delete(KEYS[:star_users])
  users = User.stars

  users.each do |user|
    UserMailer.decide_star_user(user)    
  end

end
