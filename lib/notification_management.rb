module DW

  # Set of classes and methods for handling a generic noitifcation framework
  #
  module NotificationManagement
    
    include ActionController::UrlWriter

    # Handle notification operations such as mobile notifications,alerts, 
    # emails on specific events
    #
    class NotificationManager

      # Email all the users on the comment thread
      #
      def self.new_comment(comment_id)
        comment   = Comment.with_user.find(comment_id)
        user_ids  = Comment.user_ids_in_thread_with(comment)
        users     = User.find_all_by_id(user_ids)

        users.each do |user|
          UserMailer.decide_new_comment(
                      comment,
                      user) unless user.id == comment.user.id
        end
      end
      
      # Host the new product image
      #
      def self.new_product(product_id)
        product = Product.find(product_id)
        product.host
      end

      # Host the updated product image
      #
      def self.update_product(product_id)
        product = Product.find(product_id)
        product.host
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
          Following.add(user_id,follower.id,false)
          Following.add(follower.id,user_id)
        end

        Contact.batch_insert(user_id,fb_friends_ids,fb_friends_names)

        user.has_contacts_mined = true
        user.save!
      end

      # Email the owner about any action taken on his product
      #
      def self.new_action(action_id)
        action  = Action.find(action_id)

        UserMailer.decide_new_action(
                    action) unless action.user_id == action.product.user_id
      end

      # Email the user whenever someone follows him/her
      # 
      def self.new_following(following_id)
        following = Following.find(following_id)

        user      = following.user
        follower  = following.follower

        UserMailer.decide_new_follower(follower,user) 
      end
    
    end #notification manager

  end #notification management

end #dw
