class YahooController < ApplicationController
  
  def new
    @target_url = yh_reply_url

    @consumer = OAuth::Consumer.new(
                                CONFIG[:yahoo_consumer_key],
                                CONFIG[:yahoo_consumer_secret], 
                                :site => 'https://api.login.yahoo.com',
                                :access_token_path  => '/oauth/v2/get_token',
                                :authorize_path     => '/oauth/v2/request_auth',
                                :request_token_path => '/oauth/v2/get_request_token')

    request_token = @consumer.get_request_token
    session[:yahoo_request_token] = request_token

    @target_url = request_token.authorize_url
    redirect_to @target_url
  end

  def create
    raise params.to_yaml
    #render :text => request.env['omniauth.auth'].to_yaml
    #@usage = params[:usage] ? params[:usage].to_sym : :popup
    #@error = params[:error]

    #unless @error
    #  case @usage
    #  when :popup
    #    credentials = request.env['omniauth.auth']['credentials']
    #    info = request.env['omniauth.auth']['info']

    #    self.current_user.go_token = credentials['token']
    #    self.current_user.go_secret = credentials['secret'] 
    #    self.current_user.go_email = info['email']
    #    self.current_user.save!
    #  end
    #end

  #rescue => ex
  #  handle_exception(ex)
  #ensure
  end
end
