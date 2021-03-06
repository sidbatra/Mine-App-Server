class YahooController < ApplicationController
  before_filter :login_required

  def create
    @usage = params[:usage] ? params[:usage].to_sym : :popup
    @error = params[:error]

    unless @error
      case @usage
      when :popup
        credentials = request.env['omniauth.auth']['credentials']
        info = request.env['omniauth.auth']['info']
        extra = request.env['omniauth.auth']['extra']

        self.current_user.yh_token = credentials['token']
        self.current_user.yh_secret = credentials['secret'] 
        self.current_user.yh_email = info['email']
        self.current_user.yh_session_handle = extra['access_token'].params['oauth_session_handle']
        self.current_user.save!
      end
    end

  rescue => ex
    handle_exception(ex)
  ensure
  end
end
