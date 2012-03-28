module DW

  # Set of classes and methods for interfacing with the email service
  #
  module MailmanInterface

    # Mailman wraps around UserMailer and abstracts the logic
    # to generate complex emails
    #
    class Mailman

      # Email the owner about any action on a product
      #
      def self.notify_owner_about_an_action(action)
        
        if action.actionable.user.setting.email_interaction &&
                action.user_id != action.actionable.user_id

          UserMailer.deliver_new_action(action) 
        end
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email user being followed
      #
      def self.email_leader_about_follower(following)
        
        if following.user.setting.email_influencer
          UserMailer.deliver_new_follower(following) 
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Welcome email for the new user
      #
      def self.welcome_new_user(user)
        UserMailer.deliver_new_user(user)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email admins when a user is deleted
      #
      def self.email_admin_about_deleted_user(user)
        admin = User.find_all_by_is_admin(true).first
        UserMailer.deliver_user_deleted(admin,user)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Prompt given users to create another product 
      #
      def self.prompt_users_to_create_another_product(users)
        users.each do |user|
          begin
            if user.setting.email_update
              UserMailer.deliver_create_another_product(user)
              sleep 0.09
            end
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)    
          end
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email users with a digest of their friends 
      # wants and owns
      #
      def self.email_users_friend_activity_digest(
                users,active_users,owns_hash,wants_hash)
                
        users.each do |user|
          begin
            if user.setting.email_influencer
              friends         = user.ifollowers
              active_friends  = friends.select{|f| active_users.include? f.id} 

              owns            = active_friends.map{|f| owns_hash[f.id]}
              wants           = active_friends.map{|f| wants_hash[f.id]}

              UserMailer.deliver_friend_activity_digest(
                          user,
                          active_friends,
                          owns,
                          wants)
              sleep 0.09
            end
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)    
          end
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email users with no items to try and win them back
      #
      def self.pester_users_with_no_items(users)
        pester_users(users,:deliver_add_an_item)
      end

      # Email users with no friends to try and make them invite
      #
      def self.pester_users_with_no_friends(users)
        pester_users(users,:deliver_add_a_friend)
      end

      # Email users with no stores to try and make them add stores
      #
      def self.pester_users_with_no_stores(users)
        pester_users(users,:deliver_add_a_store)
      end


      protected

      # Generic methods that iterates over the given users
      # and calls the given mailer method with only the user
      # as an argument. Primary usage are the multiple pester
      # methods that fire on different triggers
      #
      def self.pester_users(users,mailer_method)
        users.each do |user|
          begin
            if user.setting.email_update
              UserMailer.send(mailer_method,user)
              sleep 0.09
            end
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)    
          end
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

    end #mailman

  end #mailman interface

end #dw
