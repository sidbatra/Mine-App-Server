# Handle requests for displaying and updating
# user settings
#
class SettingsController < ApplicationController
  before_filter :login_required

  # Display the settings available to the current user
  #
  def index
    @settings = self.current_user.setting
  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to(root_path) if @error
  end

  # Get the status of individual settings for the current user 
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

  # Update settings for the current iser
  #
  def update
    @settings = self.current_user.setting
    @settings.update_attributes(params[:setting])
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do 
        redirect_to settings_path(:src => @error ? 'error' : 'saved')
      end
      format.json 
    end
  end
end
