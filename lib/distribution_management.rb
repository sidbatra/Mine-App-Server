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
                                    :host => CONFIG[:host])) 
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
                                    collection.id,
                                    :src  => 'fb',
                                    :host => CONFIG[:host])) 
    end
    
    end #distribution manager

  end #distribution management

end #dw
