module DW

  # Set of classes and methods for handling a generic noitifcation framework
  #
  module NotificationManagement
    
    include ActionController::UrlWriter

    # Handle notification operations such as mobile notifications,alerts, 
    # emails on specific events
    #
    class NotificationManager

      
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
