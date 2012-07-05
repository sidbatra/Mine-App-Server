class SettingsController < ApplicationController
  before_filter :login_required

  # Display page for editing settings of the current user.
  #
  def index
    @settings = self.current_user.setting
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Get the status of individual settings for the current user.
  #
  def show
    @filter = params[:id].to_sym

    case @filter
    when :fb_publish_permissions
      @setting = {:status => self.current_user.fb_publish_permissions?}

    when :fb_auth
      @setting = {:status => self.current_user.fb_authorized?}

    when :tw_auth
      @setting = {:status => self.current_user.tw_authorized?}

    when :tumblr_auth
      @setting = {:status => self.current_user.tumblr_authorized?}

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

    if params[:id] && params[:value]
      @filter = params[:id].to_sym

      case @filter
      when :fb_publish_permissions
        attributes = {:fb_publish_actions => params[:value]}

      else
        attributes = {params[:id] => params[:value]}
      end

      @settings.update_attributes(attributes)

    else
      @settings.update_attributes(params[:setting])
    end

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
