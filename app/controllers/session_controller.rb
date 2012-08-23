class SessionController < ApplicationController

  # Create a new session. Route assumes that the curent user id
  # is stored in session[:user_id]
  #
  # This construct enables logins which are blind to the connect
  # mechanism used.
  #
  def create
    target = params[:target]
    follow_user_id = params[:follow_user_id]

    user = User.find session[:user_id]

    if user
      self.current_user = user
      set_cookie

      Following.add(follow_user_id,self.current_user.id) if follow_user_id
    end

  rescue => ex
    handle_exception(ex)
  ensure
    url = ""

    if @error
      url = root_path(:src => HomeShowSource::LoginError)
    elsif target
      url = target
    else
      url = root_path(:src => FeedShowSource::Login)
    end

    redirect_to url
  end

  # Delete the current session and remove all existing cookie
  # related data for the current user.
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
