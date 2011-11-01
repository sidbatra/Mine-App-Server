# Handle requests for the session lifecycle
#
class SessionController < ApplicationController

  # Display the login page
  #
  def new
  end

  # Create a session by asking user to enter via facebook
  #
  def create
    source              = params[:source] ? params[:source].to_s : "unknown"
    fb_auth             = FbGraph::Auth.new(
                            CONFIG[:fb_app_id],
                            CONFIG[:fb_app_secret])
    client              = fb_auth.client
    client.redirect_uri = fb_reply_url(:source => source)

    target_url          =  client.authorization_uri(
                            :scope => [:email,:user_likes,:user_birthday])
  rescue => ex
    handle_exception(ex)
    target_url = root_path(:src => "login_error")
  ensure
    redirect_to target_url
  end

  # Delete the current session and remove all existing cookie
  # related data for the current user
  #
  def destroy
    self.current_user.forget if logged_in?
    delete_cookie
    reset_session

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to root_path(:src => "logout_error")
  end

end
