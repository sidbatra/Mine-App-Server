desc "Email new followers to suggested users"

task :email_new_followers_to_suggested_users do |e,args|
  
  require 'config/environment.rb'

    puts "DEPRECATED - User.to_follow isn't used anymore"
 
    User.to_follow.each do |user|
      begin
        last_email  = Email.find_last_by_purpose_and_recipient_id(
                        EmailPurpose::NewBulkFollowers,
                        user.id)

        time_from   = last_email ? last_email.created_at : 1.day.ago 

        followings  = Following.find_all_by_user_id(user.id,
                                  :conditions => {
                                    :source     => 'suggestion',
                                    :created_at => time_from..Time.now,
                                    :is_active  => true},
                                  :include    => :follower)
                                          
        if followings.present?
          UserMailer.deliver_new_bulk_followers(user,followings) 
          puts user.handle
          sleep 0.4
        else
          puts "no new followers for #{user.handle}"
        end
      rescue => ex
        puts "#{ex.to_s} for #{user.handle}"
        LoggedException.add(__FILE__,__method__,ex)    
      end#begin_user
    end#user

end
