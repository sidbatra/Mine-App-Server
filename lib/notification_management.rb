module DW

  module NotificationManagement
    
    class NotificationManager

      def self.new_like(like)
        target_user   = like.purchase.user
        entity        = like.user.full_name
        event         = "your #{like.purchase.title}"
        total_likes   = like.purchase.likes.count

        if total_likes > 1
          event = "and #{total_likes-1} "\
                  "#{total_likes-1 == 1 ? "other" : "others"} like #{event}"
        else
          event = "likes #{event}"
        end

        Notification.add(
                      target_user.id,
                      entity,
                      event,
                      like.purchase,
                      like.user.square_image_url,
                      NotificationIdentifier::Like)
      end

    end #notification manager

  end #notification management

end #dw

