class SessionController < ApplicationController

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
