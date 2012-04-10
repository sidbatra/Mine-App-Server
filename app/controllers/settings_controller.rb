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
    when :publish_stream
      @setting = {:status => self.current_user.fb_permissions.include?(@filter)}
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
      @settings.update_attributes(params[:id] => params[:value])
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
        redirect_to settings_path(:src => @error ? 'error' : 'saved')
      end
      format.json 
    end
  end
end
