module DW

  # Set of classes and methods for interfacing with the email service
  #
  module MailmanInterface

    # Mailman wraps around UserMailer and abstracts the logic
    # to generate complex emails
    #
    class Mailman

      # Welcome email for the new user
      #
      def self.welcome_new_user(user)
        UserMailer.deliver_new_user(user)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Public. Email users with a suggestion based on their
      # current suggestion filling progress.
      #
      def self.after_join_suggestions
        yest = Time.now - 24.hours
        start = DateTime.new(yest.year,yest.month,yest.day,0,0,0)
        finish = DateTime.new(yest.year,yest.month,yest.day,23,59,59)

        suggestions = Suggestion.select(:id,:title,:thing,:example,:image_path).
                        by_weight.limit(3)

        User.with_purchases.with_setting.made(start,finish).each do |user|
          begin
            suggestions_done_ids = user.purchases.map(&:suggestion_id).uniq.compact

            if user.setting.email_update && suggestions_done_ids.length < suggestions.length
              UserMailer.deliver_after_join_suggestions(user,suggestions,suggestions_done_ids)
            end

            sleep 0.09
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)
          end
        end

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

      # Public. Email users whose friends have added purchases.
      #
      # users - The Array of User objects whose friends have added purchases.
      # purchases - The Hash with keys as user ids who have added 
      #                     purchases and values as Arrays of their purchases.
      #
      def self.email_users_friend_activity_digest(users,purchases,from)
                
        users.each do |user|
          begin
            if user.setting.email_influencer
              friends = user.ifollowers
              active_friends = friends.select{|f| purchases.key?(f.id)}
              new_friends = friends.select{|f| f.created_at > from}

              #friends_purchases = active_friends.map{|f| purchases[f.id]}
              friends_purchases = []
              
              UserMailer.deliver_friend_activity_digest(
                          user,
                          active_friends,
                          new_friends,
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

      # Public. Email users with a reminder to add new purchases.
      #
      def self.add_purchase_reminder

        User.with_setting.each do |user|
          begin

            if user.setting.email_update 
              UserMailer.deliver_add_purchase_reminder(user)
            end

            sleep 0.09
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
