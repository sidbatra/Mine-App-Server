module DW

  # Set of classes and methods for handling a generic notifcation framework
  #
  module NotificationManagement
    
    include ActionController::UrlWriter

    # Handle notification operations such as mobile notifications,alerts, 
    # emails on specific events
    #
    class NotificationManager

      # Notify Mailman about the new following
      # 
      def self.new_following(following_id)
        following = Following.find(following_id)
        Mailman.email_leader_about_follower(following)
      end

    end #notification manager

  end #notification management

end #dw
