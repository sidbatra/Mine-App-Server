module DW

  # Set of classes and methods for handling a generic notifcation framework
  #
  module NotificationManagement
    
    include ActionController::UrlWriter

    # Handle notification operations such as mobile notifications,alerts, 
    # emails on specific events
    #
    class NotificationManager

      # Notify mailman about new comment
      #
      def self.new_comment(comment_id)
        comment = Comment.with_user.find(comment_id)
        Mailman.email_users_in_comment_thread(comment)
      end
      
      # Host the new product image
      #
      def self.new_product(product_id)
        product = Product.find(product_id)
        product.host

        if product.user.setting.post_to_timeline
          DistributionManager.publish_add(product)
        end
      end

      # Host the updated product image
      #
      def self.update_product(product_id)
        product = Product.find(product_id)
        product.host
      end

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

      # Process a new collection and manage distribution
      #
      def self.new_collection(collection_id)
        collection = Collection.find(collection_id)
        collection.process

         Mailman.email_followers_about_collection(collection)

        if collection.user.setting.post_to_timeline
          DistributionManager.publish_use(collection)
        end
      end

      # Update a collection
      #
      def self.update_collection(collection_id)
        collection = Collection.find(collection_id)
        collection.process
      end
    
    end #notification manager

  end #notification management

end #dw
