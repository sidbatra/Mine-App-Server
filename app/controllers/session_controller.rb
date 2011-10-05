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
    client              = FB_AUTH.client
    client.redirect_uri = fb_reply_url 

    target_url          =  client.authorization_uri(
                            :scope => [:email,:user_likes,
                                       :user_birthday,:publish_stream,
                                       :offline_access])
  rescue => ex
    handle_exception(ex)
    target_url = root_path
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
    redirect_to root_path
  end

end
