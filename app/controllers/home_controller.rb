# Handle requests for the home page
#
class HomeController < ApplicationController
layout 'home'

  # Display pre-selected products on the home page
  #
  def show
    @source    = params[:id] ? params[:id].to_s : "unknown"

    redirect_to user_path(self.current_user) if logged_in?
  end

end
