class TwitterController < ApplicationController

  def create
    @filter = params[:filter].to_sym

    client = TwitterOAuth::Client.new(
                :consumer_key     => CONFIG[:tw_consumer_key], 
                :consumer_secret  => CONFIG[:tw_consumer_secret]) 

    case @filter
    when :authenticate
      request_token = client.request_token(:oauth_callback => tw_reply_url)
      session[:tw_request_token] = request_token
      redirect_to request_token.authorize_url

    when :reply
      oauth_verifier = params[:oauth_verifier]

      if oauth_verifier
        access_token = client.authorize(
                                session[:tw_request_token].token,
                                session[:tw_request_token].secret,
                                :oauth_verifier => oauth_verifier)  

        self.current_user.tw_access_token = access_token.token
        self.current_user.tw_access_token_secret = access_token.secret
        self.current_user.tw_user_id = access_token.params['user_id']

        self.current_user.save!
      end
    else
      raise IOError, "Incorrect twitter create filter"
    end

  rescue => ex
    handle_exception(ex)
  end

end
