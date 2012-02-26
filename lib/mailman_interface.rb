module DW

  # Set of classes and methods for interfacing with the email service
  #
  module MailmanInterface

    # Mailman wraps around UserMailer and abstracts the logic
    # to generate complex emails
    #
    class Mailman

      # Email the owner about any action on a collection or product
      #
      def self.notify_owner_about_an_action(action)
        
        if action.actionable.user.setting.email_interaction &&
                action.user_id != action.actionable.user_id

          UserMailer.deliver_new_action(action) 
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
            
            if user.setting.email_interaction && 
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

      # Email user being followed
      #
      def self.email_leader_about_follower(following)
        
        if following.user.setting.email_influencer
          UserMailer.deliver_new_follower(following) 
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email followers of a user about a freshly added collection
      #
      def self.email_followers_about_collection(collection)
        collection.user.followers.with_setting.each do |follower|
          begin
            if follower.setting.email_influencer
              UserMailer.deliver_friend_collection(follower,collection)
              sleep 0.09
            end
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)
          end
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

      # Notify top shoppers at a store about their achievement
      #
      def self.notify_top_shoppers(store,top_shoppers)
        top_shoppers.each do |user|
          begin 
            if user.setting.email_update
              UserMailer.deliver_top_shopper(user,store)    
              sleep 0.09
            end
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)    
          end
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Prompt given users to create another collection
      #
      def self.prompt_users_to_create_another_collection(users)
        users.each do |user|
          begin
            if user.setting.email_update
              UserMailer.deliver_create_another_collection(
                          user,
                          user.collections.last)
              sleep 0.09
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

      # Email users with no collection to try and make them add collections
      #
      def self.pester_users_with_no_collections(users)
        pester_users(users,:deliver_add_a_collection)
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
