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
        new_access_token = request_token.get_access_token(
                            :oauth_session_handle => @user_session_handle,
                            :token => token)

        {:token => new_access_token.token,
          :secret => new_access_token.secret,
          :handle => new_access_token.params['oauth_session_handle']}
      end

      def find_emails(from,after)
        emails = []
        query = "SELECT messageInfo.mid,messageInfo.receivedDate FROM "\
                "ymail.messages WHERE numInfo='100' AND "\
                "messageInfo.receivedDate > #{after.to_i} "\
                "AND fr='#{from}' | "\
                "sort(field='messageInfo.receivedDate', descending='true')"

        response = JSON.parse(execute_yql query)
        count = response["query"]["count"]

        if count && !count.zero?
          response["query"]["results"]["result"].each do |result|
            messageInfo = result["messageInfo"]
            emails << {:mid => messageInfo["mid"]}
          end
        end

        emails
      end

      def fetch_email_contents(mids)
        email_contents = []
        query = "SELECT message.mid,message.subject,message.receivedDate,"\
                "message.part.text "\
                "FROM ymail.msgcontent WHERE mids IN (\"#{mids.join("\",\"")}\") "\
                "AND message.part.subtype = 'html'"
        
        response = JSON.parse(execute_yql query)
        count = response["query"]["count"]

        if count && !count.zero?
          results = response["query"]["results"]["result"] 
          results = [results] if results.is_a? Hash

          results.each do |result|
            message = result["message"]
            email_contents << {:mid => message["mid"],
                                :subject => message["subject"],
                                :date => Time.at(message["receivedDate"].to_i),
                                :text => message["part"]["text"]}
          end
        end

        email_contents
      end

      def execute_yql(query)
        url = "http://query.yahooapis.com/v1/yql?q=#{URI.escape query}&format=json"
        access_token.get(url).body
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

      def access_token
        @access_token ||= OAuth::AccessToken.from_hash consumer,{
                            :oauth_token => @user_token,
                            :oauth_token_secret => @user_secret}
      end

      def token
        @token ||= OAuth::Token.new @user_token,@user_secret
      end

    end #yahoo api

  end #yahoo api interface

end #dw
