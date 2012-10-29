module DW

  module YahooAPIInterface
    
    class YahooAPI
      
      def initialize(user_token,user_secret,user_session_handle="")
        @user_token = user_token
        @user_secret = user_secret
        @user_session_handle = user_session_handle
      end

      # Fetch a new access_token. Returns the new access_token's
      # token, secret and session_handle in a hash.
      #
      def refresh_access_token
        access_token = request_token.get_access_token(
                        :oauth_session_handle => @user_session_handle,
                        :token => token)

        {:token => access_token.token,
          :secret => access_token.secret,
          :handle => access_token.params['oauth_session_handle']}
      end


      private

      def consumer
        @consumer ||= OAuth::Consumer.new( 
                        CONFIG[:yahoo_consumer_key],
                        CONFIG[:yahoo_consumer_secret],
                        :access_token_path  => '/oauth/v2/get_token',
                        :authorize_path     => '/oauth/v2/request_auth',
                        :request_token_path => '/oauth/v2/get_request_token',
                        :site               => 'https://api.login.yahoo.com')
      end

      def request_token
        @request_token ||= OAuth::RequestToken.new consumer,@user_token,@user_secret
      end

      def token
        @token ||= OAuth::Token.new @user_token,@user_secret
      end

    end #yahoo api

  end #yahoo api interface

end #dw
