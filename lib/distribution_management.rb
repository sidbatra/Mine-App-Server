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

        message = ""

        if purchase.endorsement.present?
          message << purchase.endorsement 
        else
          message << "Bought my #{purchase.title}" 

          if purchase.store
            message << " from #{purchase.store.name}"
          end
        end

        message << " "
        message << short_purchase_url(
                    Cryptography.obfuscate(purchase.id),
                    :host => CONFIG[:host])

        action  = fb_user.og_action!(
                    OGAction::Share,
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
        Twitter.configure do |config|
          config.consumer_key       = CONFIG[:tw_consumer_key]
          config.consumer_secret    = CONFIG[:tw_consumer_secret]
          config.oauth_token        = purchase.user.tw_access_token
          config.oauth_token_secret = purchase.user.tw_access_token_secret 
        end

        message = ""

        if purchase.endorsement.present?
          message << purchase.endorsement 
        else
          message << "Bought my #{purchase.title}" 

          if purchase.store
            message << " from #{purchase.store.name}"
          end
        end
        
       message = truncate(message,:length => 115)

        message << " "
        message << short_purchase_url(
                    Cryptography.obfuscate(purchase.id),
                    :host => CONFIG[:host])

        tweet = Twitter.update(message)
        purchase.update_attributes({:tweet_id => tweet.id})

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Post the purchase to the owners tumblr blog 
      #
      def self.post_to_tumblr(purchase)
        Tumblife.configure do |config|
          config.consumer_key       = CONFIG[:tumblr_consumer_key]
          config.consumer_secret    = CONFIG[:tumblr_consumer_secret]
          config.oauth_token        = purchase.user.tumblr_access_token 
          config.oauth_token_secret = purchase.user.tumblr_access_token_secret
        end

        client  = Tumblife.client
        name    = client.info.user.blogs.select{|blog| blog.primary}.first.name
        url     = name + '.tumblr.com'


        message = "Bought my #{purchase.title}"

        if purchase.store 
          message << " from #{purchase.store.name}"
        end

        if purchase.endorsement.present?
          message << ". "
          message << purchase.endorsement 
        end

        message << " "
        message << short_purchase_url(
                    Cryptography.obfuscate(purchase.id),
                    :host => CONFIG[:host])

        post = client.photo(
                        url,
                        :source   => purchase.unit_url,
                        :caption  => message,
                        :link     => purchase_url(
                                        purchase.user.handle,
                                        purchase.handle,
                                        :src  => 'tumblr',
                                        :host => CONFIG[:host]))

        purchase.update_attributes({:tumblr_post_id => post["id"]})

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

      # Delete a tweet. 
      #
      def self.delete_tweet(tweet_id,user)
        Twitter.configure do |config|
          config.consumer_key       = CONFIG[:tw_consumer_key]
          config.consumer_secret    = CONFIG[:tw_consumer_secret]
          config.oauth_token        = user.tw_access_token
          config.oauth_token_secret = user.tw_access_token_secret 
        end

        Twitter.status_destroy(tweet_id)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Delete a tumblr blog post
      #
      def self.delete_tumblr_post(tumblr_post_id,user)
        Tumblife.configure do |config|
          config.consumer_key       = CONFIG[:tumblr_consumer_key]
          config.consumer_secret    = CONFIG[:tumblr_consumer_secret]
          config.oauth_token        = user.tumblr_access_token 
          config.oauth_token_secret = user.tumblr_access_token_secret
        end

        client = Tumblife.client
        name   = client.info.user.blogs.select{|blog| blog.primary}.first.name
        url    = name + '.tumblr.com'

        client.delete(url,tumblr_post_id)

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
          'callback_url'  => facebook_subscriptions_url(
                              :host => CONFIG[:host]),
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
