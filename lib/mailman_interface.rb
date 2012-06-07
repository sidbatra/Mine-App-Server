module DW

  # Set of classes and methods for interfacing with the email service
  #
  module MailmanInterface

    # Mailman wraps around UserMailer and abstracts the logic
    # to generate complex emails
    #
    class Mailman

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
      
      # Email the owner about a like on his/her purchase 
      #
      def self.email_owner_about_a_like(like)
        
        if like.purchase.user.setting.email_influencer &&
                like.user_id != like.purchase.user_id

          UserMailer.deliver_new_like(like) 
        end
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email all the users on the comment thread
      #
      def self.email_users_in_comment_thread(comment)
        user_ids  = Comment.user_ids_in_thread_with(comment)
        users     = User.with_setting.find_all_by_id(user_ids)

        users.each do |user|
          begin
            
            if user.setting.email_influencer && 
                user.id != comment.user.id

              UserMailer.deliver_new_comment(comment,user) 
            end
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)
          end
        end

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

      # Public. Email users whose friends have added purchases.
      #
      # users - The Array of User objects whose friends have added purchases.
      # purchases - The Hash with keys as user ids who have added 
      #                     purchases and values as Arrays of their purchases.
      #
      def self.email_users_friend_activity_digest(users,purchases)
                
        users.each do |user|
          begin
            if user.setting.email_influencer
              friends = user.ifollowers
              active_friends = friends.select{|f| purchases.key? f.id} 
              #friends_purchases = active_friends.map{|f| purchases[f.id]}
              friends_purchases = []
              
              UserMailer.deliver_friend_activity_digest(
                          user,
                          active_friends,
                          friends_purchases)

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
