class SettingsController < ApplicationController
  before_filter :login_required

  # Display page for editing settings of the current user.
  #
  def index
    @settings = self.current_user.setting
    @themes = Theme.by_weight
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Get the status of individual settings for the current user.
  #
  def show
    @filter = params[:id].to_sym

    case @filter
    when :fb_auth
      @setting = {:status => self.current_user.fb_authorized?}

    when :tw_auth
      @setting = {:status => self.current_user.tw_authorized?}

    when :tumblr_auth
      @setting = {:status => self.current_user.tumblr_authorized?}
    
    when :google_auth
      @setting = {:status => self.current_user.google_authorized?}
    
    when :yahoo_auth
      @setting = {:status => self.current_user.yahoo_authorized?}
    
    when :hotmail_auth
      @setting = {:status => self.current_user.hotmail_authorized?}

    when :fb_access_token
      @setting = {:status => self.current_user.fb_access_token_valid?}
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Update settings for the current user.
  #
  def update
    @settings = self.current_user.setting
    @settings.update_attributes(params[:setting])

    flash[:updated] = true
  rescue => ex
    handle_exception(ex)
    flash[:updated] = false
  ensure
    respond_to do |format|
      format.html do 
        redirect_to settings_path(:src => SettingsIndexSource::Updated)
      end
      format.json 
    end
  end
end
