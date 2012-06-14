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
      def self.publish_share(purchase)
        fb_app  = FbGraph::Application.new(CONFIG[:fb_app_id])
        fb_user = FbGraph::User.me(purchase.user.access_token)  

        message = "Just bought this"

        if purchase.store && purchase.store.is_approved
          message << " from #{purchase.store.name}"
        end

        message << ". "

        if purchase.endorsement.present?
          message << purchase.endorsement 
          message << " "
        end

        message << short_purchase_url(
                    Cryptography.obfuscate(purchase.id),
                    :host => CONFIG[:host])

        action  = fb_user.og_action!(
                    OGAction::Share,
                    "image[0][url]"             => purchase.unit_url,
                    "image[0][user_generated]"  => true,
                    "message"   => message,
                    "purchase"  => purchase_url(
                                    purchase.user.handle,
                                    purchase.handle,
                                    :src  => 'fb',
                                    :host => CONFIG[:host]))

        purchase.update_attributes({:fb_action_id => action.identifier})

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Tweet about the purchase 
      #
      def self.tweet(purchase)
        client = TwitterOAuth::Client.new(
                    :consumer_key     => CONFIG[:tw_consumer_key], 
                    :consumer_secret  => CONFIG[:tw_consumer_secret],
                    :token            => purchase.user.tw_access_token,
                    :secret           => purchase.user.tw_access_token_secret)
        
        if client.authorized?
          message = "just bought this " + short_purchase_url(
                                            Cryptography.obfuscate(purchase.id),
                                            :host => CONFIG[:host])

          tweet = client.update(message)
          purchase.update_attributes({:tweet_id => tweet["id"]})
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
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

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Post an invite on a friends facebook wall 
      #
      def self.post_invite_on_friends_wall(user,friend_fb_id)
        fb_friend = FbGraph::User.new(
                              friend_fb_id, 
                              :access_token => user.access_token)

        
        fb_friend.feed!(
          :message      => "I’d like to share purchases using "\
                           "#{CONFIG[:name]} — a simple service that "\
                           "will notify you when I buy something.",
          :picture      => RAILS_ENV != 'development' ? 
                                         helpers.image_path('mine_70_2x.png') :
                                         CONFIG[:host] + 
                                         helpers.image_path('mine_70_2x.png'),
          :link         => home_url(
                            "invite", 
                            :host => CONFIG[:host]),
          :name         => "Mine - Click to start yours.",
          :description  => "#{CONFIG[:description]}",
          :caption      => "#{CONFIG[:host]}")

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Subscribe to real time updates for facebook permissions
      # of our userbase 
      #
      def self.subscribe_to_fb_updates(object,fields)
        http = Net::HTTP.new('graph.facebook.com',443)
        
        params = {
          'object'        => object,
          'fields'        => fields, 
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


      protected

      # View helper methods
      #
      def self.helpers
       ActionController::Base.helpers 
      end
    
    end #distribution manager

  end #distribution management

end #dw
