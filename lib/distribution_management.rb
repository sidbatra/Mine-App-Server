module DW

  # Set of classes and methods for handling a generic distribution framework
  #
  module DistributionManagement
    
    # Handle distribution operations such as pushing actions to third  
    # party social networks like facebook and twitter.
    #
    class DistributionManager
    
      # Publish a story whenever the user adds an item
      #
      def self.publish_add(product)
        fb_app  = FbGraph::Application.new(CONFIG[:fb_app_id])
        fb_user = FbGraph::User.me(product.user.access_token)  

        action  = fb_user.og_action!(
                            OGAction::Add,
                            :item => product_url(
                                      product.user.handle,
                                      product.handle,
                                      :src  => 'fb',
                                      :host => CONFIG[:host]),
                            :expires_in => 300) 

        TickerAction.add(action.identifier,OGAction::Add,product)
      end

      # Publish a story whenever the user wants an item
      #
      def self.publish_want(user,product)
        fb_app  = FbGraph::Application.new(CONFIG[:fb_app_id])
        fb_user = FbGraph::User.me(user.access_token)  

        action  = fb_user.og_action!(
                            OGAction::Want,
                            :item => product_url(
                                      product.user.handle,
                                      product.handle,
                                      :src  => 'fb',
                                      :host => CONFIG[:host]),
                            :end_time => "4486147655") 

        TickerAction.add(action.identifier,OGAction::Want,product)
      end

      # Publish a story whenever the user uses a collection
      #
      def self.publish_use(collection)
        fb_app  = FbGraph::Application.new(CONFIG[:fb_app_id])
        fb_user = FbGraph::User.me(collection.user.access_token)  

        action  = fb_user.og_action!(
                            OGAction::Use,
                            :set => collection_url(
                                      collection.user.handle,
                                      collection.handle,
                                      :src  => 'fb',
                                      :host => CONFIG[:host]), 
                            :expires_in => 3600)

        TickerAction.add(action.identifier,OGAction::Use,collection)
      end
    
    end #distribution manager

  end #distribution management

end #dw
