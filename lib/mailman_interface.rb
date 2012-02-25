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
        UserMailer.deliver_new_action(
                    action) unless action.user_id == action.actionable.user_id
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email all the users on the comment thread
      #
      def self.email_users_in_comment_thread(comment)
        user_ids  = Comment.user_ids_in_thread_with(comment)
        users     = User.find_all_by_id(user_ids)

        users.each do |user|
          begin
            UserMailer.deliver_new_comment(
                        comment,
                        user) unless user.id == comment.user.id
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
        UserMailer.deliver_new_follower(following) 

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email followers of a user about a freshly added collection
      #
      def self.email_followers_about_collection(collection)
        collection.user.followers.each do |follower|
          begin
            UserMailer.deliver_friend_collection(follower,collection)
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
        UserMailer.deliver_user_deleted(user)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Notify top shoppers at a store about their achievement
      #
      def self.notify_top_shoppers(store,top_shoppers)
        top_shoppers.each do |user|
          begin 
            UserMailer.deliver_top_shopper(user,store)    
            sleep 0.09
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
            #UserMailer.create_another_collection(user)
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
