module DW

  # Set of classes and methods for handling a generic notifcation framework
  #
  module NotificationManagement
    
    include ActionController::UrlWriter

    # Handle notification operations such as mobile notifications,alerts, 
    # emails on specific events
    #
    class NotificationManager

      # Rehost the updated store image
      #
      def self.update_store(store_id)
        store = Store.find(store_id)
        store.host
      end

      # Notify Mailman about the new action
      #
      def self.new_action(action_id)
        action  = Action.find(action_id)
        Mailman.notify_owner_about_an_action(action)

        if action.name == ActionName::Want && 
           action.user.setting.post_to_timeline
          DistributionManager.publish_want(
                                action.user,
                                action.actionable)
        end
      end

      # Notify Mailman about the new following
      # 
      def self.new_following(following_id)
        following = Following.find(following_id)
        Mailman.email_leader_about_follower(following)
      end

    end #notification manager

  end #notification management

end #dw
