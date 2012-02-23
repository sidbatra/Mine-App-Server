namespace :users do 

  namespace :update do

    desc "Mine contacts from facebook"
    task :contacts => :environment do |e,args|

      User.find_all_by_has_contacts_mined(false).each do |user|
        begin
          fb_friends = user.fb_friends 

          Contact.batch_insert(
                          user.id,
                          fb_friends.map(&:identifier),
                          fb_friends.map(&:name))

          user.has_contacts_mined = true
          user.save!
        rescue => ex
          puts "access token error for user id #{user.id}"
          LoggedException.add(__FILE__,__method__,ex)    
        end
      end

    end  #contacts

  end #update
end #users
    
