class SessionController < ApplicationController

  # Delete the current session and remove all existing cookie
  # related data for the current user.
  #
  def destroy

    if logged_in? && 
        params[:forever] && 
        self.current_user.purchases_count.zero?
      self.current_user.destroy
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do
        self.current_user.forget if logged_in? && !self.current_user.frozen?
        delete_cookie
        reset_session
        redirect_to root_path(:src => HomeShowSource::Logout)
      end
      format.json do
        render :text => true
      end
    end
  end

end
