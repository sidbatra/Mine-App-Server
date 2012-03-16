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

        TickerAction.add(
                      action.identifier,
                      OGAction::Add,
                      product,
                      product.user_id)
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

        TickerAction.add(action.identifier,OGAction::Want,product,user.id)
      end

      # Update the published story whenever a product is updated
      #
      def self.update_add_or_want(ticker_action)
        action  = FbGraph::OpenGraph::Action.new(ticker_action.og_action_id) 
        product = ticker_action.ticker_actionable
        
        action.update(:item => product_url(
                                product.user.handle,
                                product.handle,
                                :src  => 'fb',
                                :host => CONFIG[:host]),
                      :access_token => ticker_action.user.access_token)
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

        TickerAction.add(
                      action.identifier,
                      OGAction::Use,
                      collection,
                      collection.user_id)
      end

      # Update the published story whenever a collection is updated
      #
      def self.update_use(ticker_action)
        action     = FbGraph::OpenGraph::Action.new(ticker_action.og_action_id) 
        collection = ticker_action.ticker_actionable

        action.update(:set => collection_url(
                                collection.user.handle,
                                collection.handle,
                                :src  => 'fb',
                                :host => CONFIG[:host]), 
                      :access_token => ticker_action.user.access_token)
      end

      # Delete a published story whenever a product or a collection is
      # deleted
      #
      def self.delete_story(ticker_action)
        action = FbGraph::OpenGraph::Action.new(ticker_action.og_action_id) 
        action.destroy(:access_token => ticker_action.user.access_token)
      end

      # Post an invite on a friends facebook wall 
      #
      def self.post_on_friends_wall(user,friend)
        fb_friend = FbGraph::User.new(
                              friend.fb_user_id, 
                              :access_token => user.access_token)

        
        fb_friend.feed!(
          :message      => "I set up your #{CONFIG[:name]} with style set to "\
                           "\"#{friend.byline}\"!",
          :picture      => friend.image_url, 
          :link         => user_url(
                            friend.handle,
                            :src  => UserShowSource::Invite,
                            :host => CONFIG[:host]),
          :name         => "#{friend.first_name}'s #{CONFIG[:name]}",
          :description  => "#{CONFIG[:description]}",
          :caption      => "#{CONFIG[:host]}")
      end

      # Publish added products to facebook album
      #
      def self.publish_product_to_fb_album(product)
        fb_user = FbGraph::User.me(product.user.access_token)
        fb_user.photo!(
                  :url      => product.image_url,
                  :message  => product.title)  
      end
    
    end #distribution manager

  end #distribution management

end #dw
