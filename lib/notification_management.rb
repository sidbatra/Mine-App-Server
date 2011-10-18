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
    
    end #notification manager

  end #notification management

end #dw
