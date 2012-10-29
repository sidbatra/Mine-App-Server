module DW

  module YahooAPIInterface
    
    class YahooAPI

      # Fetch a new access_token. Returns the new access_token's
      # token, secret and session_handle.
      #
      def refresh_access_token(token,secret,session_handle)
        create_consumer
        create_request_token @consumer,token,secret
        create_token token,secret

        access_token = @request_token.get_access_token(
                        :oauth_session_handle => session_handle,
                        :token => @token)

        [access_token.token,
          access_token.secret,
          access_token.params['oauth_session_handle']]
      end


      private

      def create_consumer
        @consumer ||= OAuth::Consumer.new( 
                        CONFIG[:yahoo_consumer_key],
                        CONFIG[:yahoo_consumer_secret],
                        :access_token_path  => '/oauth/v2/get_token',
                        :authorize_path     => '/oauth/v2/request_auth',
                        :request_token_path => '/oauth/v2/get_request_token',
                        :site               => 'https://api.login.yahoo.com')
      end

      def create_request_token(consumer,token,secret)
        @request_token ||= OAuth::RequestToken.new consumer,token,secret
      end

      def create_token(token,secret)
        @token ||= OAuth::Token.new token,secret
      end

    end #yahoo api

  end #yahoo api interface

end #dw
