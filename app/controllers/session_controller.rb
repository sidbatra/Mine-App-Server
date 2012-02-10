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
    fb_auth             = FbGraph::Auth.new(
                            CONFIG[:fb_app_id],
                            CONFIG[:fb_app_secret])
    client              = fb_auth.client
    client.redirect_uri = fb_reply_url(
                            :src    => @source,
                            :target => params[:target])

    target_url          = client.authorization_uri(
                            :scope => [:email,
                                       :user_likes,
                                       :user_birthday,
                                       :publish_actions])
  rescue => ex
    handle_exception(ex)
    target_url = root_path(:src => HomeShowSource::LoginError)
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
    redirect_to root_path(:src => HomeShowSource::Logout)
  end

end
