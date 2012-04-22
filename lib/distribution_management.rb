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
      def self.publish_add(purchase)
        fb_app  = FbGraph::Application.new(CONFIG[:fb_app_id])
        fb_user = FbGraph::User.me(purchase.user.access_token)  

        action  = fb_user.og_action!(
                            OGAction::Add,
                            :item => purchase_url(
                                      purchase.user.handle,
                                      purchase.handle,
                                      :src  => 'fb',
                                      :host => CONFIG[:host]))

        purchase.update_attributes({:fb_action_id => action.identifier})
      end

      # Update an open graph object - purchase
      # This updates all the actions associated with that object
      #
      def self.update_object(url)
        http = Net::HTTP.new('graph.facebook.com')
        http.request_post('/',"id=#{url}&scrape=true")

        rescue => ex
          LoggedException.add(__FILE__,__method__,ex)
      end

      # Delete a published story. 
      #
      def self.delete_story(og_action_id,access_token)
        action = FbGraph::OpenGraph::Action.new(og_action_id) 
        action.destroy(:access_token => access_token)
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

      # Publish added purchases to facebook album
      #
      def self.publish_purchase_to_fb_album(purchase)
        fb_user = FbGraph::User.me(purchase.user.access_token)
        photo = fb_user.photo!(
                  :url      => purchase.image_url,
                  :message  => purchase.title)  

        purchase.update_attributes({:fb_photo_id => photo.identifier})
      end

      # Subscribe to real time updates for facebook permissions
      # of our userbase 
      #
      def self.subscribe_to_fb_permissions_updates
        http = Net::HTTP.new('graph.facebook.com',443)
        
        params = {
          'object'        => 'permissions',
          'fields'        => 'publish_actions,publish_stream',
          'callback_url'  => facebook_index_url(
                              :host   => CONFIG[:host],
                              :filter => 'subscriptions'),
          'verify_token'  => CONFIG[:fb_verify_token],
          'access_token'  => CONFIG[:fb_app_token]}

        http.use_ssl      = true
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE

        http.request_post(
              "/#{CONFIG[:fb_app_id]}/subscriptions",
              params.map{|k,v| "#{k}=#{v}"}.join('&'))

        rescue => ex
          LoggedException.add(__FILE__,__method__,ex)
      end
    
    end #distribution manager

  end #distribution management

end #dw
