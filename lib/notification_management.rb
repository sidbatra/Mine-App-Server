module DW

  module NotificationManagement
    
    class NotificationManager

      def self.new_like(like)
        target_user   = like.purchase.user
        entity        = like.user.full_name
        event         = ""
        total_likes   = like.purchase.likes.count

        if total_likes > 1
          event = "and #{total_likes-1} "\
                  "#{total_likes-1 == 1 ? "other" : "others"} like"
        else
          event = "likes"
        end

        event << " your #{like.purchase.title}."

        Notification.add(
                      target_user.id,
                      entity,
                      event,
                      like.purchase,
                      like.user.square_image_url,
                      NotificationIdentifier::Like)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end #new like


      def self.new_comment(comment,users)
        owner = comment.purchase.user
        entity = comment.user.full_name

        users.each do |user|
          event = ""

          if owner.id == user.id
            event = "commented on your"
          elsif owner.id == comment.user_id
            event = "also commented on #{owner.is_male? ? 'his' : 'her'}"
          else
            event = "also commented on #{owner.first_name}'s"
          end

          event << " #{comment.purchase.title}."

          Notification.add(
                        user.id,
                        entity,
                        event,
                        comment.purchase,
                        comment.user.square_image_url,
                        NotificationIdentifier::Comment)
        end #users

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end #new comment


      def self.new_following(following)
        target_user   = following.user
        entity        = following.follower.full_name
        event         = "is following you."

        Notification.add(
                      target_user.id,
                      entity,
                      event,
                      following.follower,
                      following.follower.square_image_url,
                      NotificationIdentifier::Following)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end #new following

    end #notification manager


    # Stub resource for notification objects that don't map
    # to an existing active record objet.
    #
    class StubResource < ActiveRecord::Base
      set_table_name 'settings'
    end

  end #notification management

end #dw

