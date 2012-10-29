module DW

  module YahooAPIInterface
    
    class YahooAPI


      # Fetch a new access_token. Returns the new access_token's
      # token, secret and session_handle.
      #
      def self.refresh_access_token(token,secret,session_handle)
        consumer = create_consumer
        request_token = create_request_token consumer,token,secret
        token = create_token token,secret

        access_token = request_token.get_access_token(
                        :oauth_session_handle => session_handle,
                        :token => token)

        [access_token.token,
          access_token.secret,
          access_token.params['oauth_session_handle']]
      end


      private

      def self.create_consumer
        OAuth::Consumer.new( 
          CONFIG[:yahoo_consumer_key],
          CONFIG[:yahoo_consumer_secret],
          :access_token_path  => '/oauth/v2/get_token',
          :authorize_path     => '/oauth/v2/request_auth',
          :request_token_path => '/oauth/v2/get_request_token',
          :site               => 'https://api.login.yahoo.com')
      end

      def self.create_request_token(consumer,token,secret)
        OAuth::RequestToken.new consumer,token,secret
      end

      def self.create_token(token,secret)
        OAuth::Token.new token,secret
      end

    end #yahoo api

  end #yahoo api interface

end #dw
