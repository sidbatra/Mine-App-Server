class TwitterController < ApplicationController

  def create
    @filter = params[:filter].to_sym

    client = TwitterOAuth::Client.new(
                :consumer_key => '5M8DIWAdEJRKlTW5d9vw',
                :consumer_secret => 'JSSRkH53nsTbvppypEmsmWJHini1CE0PJuwWV8ck4sc')

    case @filter
    when :authenticate
      request_token = client.request_token(:oauth_callback => tw_reply_url)
      session[:request_token] = request_token
      redirect_to request_token.authorize_url
    when :reply
      access_token = client.authorize(
                              session[:request_token].token,
                              session[:request_token].secret,
                              :oauth_verifier => params[:oauth_verifier])  

      self.current_user.tw_access_token = access_token.token
      self.current_user.tw_access_token_secret = access_token.secret

      self.current_user.save!
    else
      raise IOError, "Incorrect twitter create filter"
    end

  rescue => ex
    handle_exception(ex)
  end

end
