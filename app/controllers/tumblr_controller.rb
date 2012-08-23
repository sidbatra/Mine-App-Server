class TumblrController < ApplicationController

  # Start the tumblr authentication process.
  #
  def new
    @consumer = OAuth::Consumer.new(
                                CONFIG[:tumblr_consumer_key], 
                                CONFIG[:tumblr_consumer_secret], 
                                :site => 'http://www.tumblr.com')

    request_token = @consumer.get_request_token
    session[:tumblr_request_token] = request_token

    redirect_to request_token.authorize_url

  rescue => ex
    handle_exception(ex)
  end

  # Handle reply from tumblr oauth.
  #
  def create
    oauth_verifier = params[:oauth_verifier]

    if oauth_verifier
      request_token = session[:tumblr_request_token]
      access_token  = request_token.get_access_token(
                                      :oauth_verifier => oauth_verifier) 

      self.current_user.tumblr_access_token = access_token.token
      self.current_user.tumblr_access_token_secret = access_token.secret

      self.current_user.save!
    end

  rescue => ex
    handle_exception(ex)
  end

end
