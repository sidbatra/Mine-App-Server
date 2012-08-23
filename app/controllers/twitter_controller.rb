class TwitterController < ApplicationController
  before_filter :create_client

  # Start the twitter authentication process.
  #
  def new
    request_token = @client.request_token(:oauth_callback => tw_reply_url)
    session[:tw_request_token] = request_token
    redirect_to request_token.authorize_url

  rescue => ex
    handle_exception(ex)
  end

  # Handle replies from twitter oauth.
  #
  def create
    oauth_verifier = params[:oauth_verifier]

    if oauth_verifier
      access_token = @client.authorize(
                              session[:tw_request_token].token,
                              session[:tw_request_token].secret,
                              :oauth_verifier => oauth_verifier)  

      self.current_user.tw_access_token = access_token.token
      self.current_user.tw_access_token_secret = access_token.secret
      self.current_user.tw_user_id = access_token.params['user_id']

      self.current_user.save!
    end

  rescue => ex
    handle_exception(ex)
  end


  private

  # Create a twitter client variable.
  #
  def create_client
    @client = TwitterOAuth::Client.new(
                :consumer_key     => CONFIG[:tw_consumer_key], 
                :consumer_secret  => CONFIG[:tw_consumer_secret]) 
  end

end
