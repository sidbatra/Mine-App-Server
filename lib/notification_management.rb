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
        comment   = Comment.eager.find(comment_id, :include => :product)
        users     = User.commented_on_product(comment.product.id) 
        users    << comment.product.user

        users.uniq.each do |user|
          UserMailer.deliver_new_comment(
                      comment,
                      user) unless user.id == comment.user.id
        end
      end
      
      # Share the new product on facebook
      #
      def self.new_product(product_id)
        product = Product.find(product_id,:include => :user)
        product.share(
          product_url(
            product.id,
            product.handle,
            :src => "fb",
            :host => CONFIG[:host]))
      end
      
      # Create friendships based on FB friends when a user is created
      #
      def self.new_user(user_id)
        user        = User.find(user_id)
        fb_user     = FbGraph::User.new('me', 
                                        :access_token => user.access_token) 
        fb_friends  = fb_user.friends.map(&:identifier)
        friends     = User.find_all_by_fb_user_id(fb_friends)
      end
    
    end #notification manager

  end #notification management

end #dw
