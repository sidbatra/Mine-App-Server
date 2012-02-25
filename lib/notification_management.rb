module DW

  # Set of classes and methods for handling a generic noitifcation framework
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

        #if product.user.setting.post_to_timeline
        #  DistributionManager.publish_add(product)
        #end
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
      
      # Make a user follow all his Facebook friends in our user base 
      # and email the friends about his signup. Also store all their
      # friends in the contacts table
      #
      def self.new_user(user_id)
        user              = User.find(user_id)
        fb_friends        = user.fb_friends

        fb_friends_ids    = fb_friends.map(&:identifier)
        fb_friends_names  = fb_friends.map(&:name)

        followers         = User.find_all_by_fb_user_id(fb_friends_ids)

        followers.each do |follower|
          Following.add(user_id,follower.id,FollowingSource::Auto,false)
          Following.add(follower.id,user_id,FollowingSource::Auto)
        end

        Contact.batch_insert(user_id,fb_friends_ids,fb_friends_names)

        user.has_contacts_mined = true
        user.save!

        Mailman.welcome_new_user(user)
      end

      # Notify Mailman about the new actin
      #
      def self.new_action(action_id)
        action  = Action.find(action_id)
        Mailman.noitify_owner_about_an_action(action)
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

        #if collection.user.setting.post_to_timeline
        #  DistributionManager.publish_use(collection)
        #end
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
