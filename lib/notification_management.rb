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
        comment   = Comment.with_user.with_product.find(comment_id)
        users     = User.commented_on_product(comment.product.id) 
        users    << comment.product.user

        users.uniq.each do |user|
          UserMailer.decide_new_comment(
                      comment,
                      user) unless user.id == comment.user.id
        end
      end
      
      # Share the new product on facebook
      #
      def self.new_product(product_id)
        product = Product.find(product_id)
        product.host
      end
      
      # Make a user follow all his Facebook friends in our user base 
      # and email the friends about his signup.
      #
      def self.new_user(user_id)
        user        = User.find(user_id)
        fb_user     = FbGraph::User.new('me', 
                                        :access_token => user.access_token) 
        fb_friends  = fb_user.friends.map(&:identifier)
        followers   = User.find_all_by_fb_user_id(fb_friends)

        followers.each do |follower|
          Following.add(user_id,follower.id,false)
          Following.add(follower.id,user_id)
        end
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
