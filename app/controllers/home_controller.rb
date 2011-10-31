# Handle requests for the home page
#
class HomeController < ApplicationController
layout :decide_layout

  # Display pre-selected products on the home page
  #
  def show
    @source   = params[:id] ? params[:id].to_s : "unknown"
    @layout   = 'home1'
    @layout   = 'home2' if @source == "home2"

  
    page = "show1"
    page = "show2" if @layout == "home2"

    if logged_in? 
      redirect_to user_path(self.current_user) 
    else
      render page
    end
  end

  private 

  # Decide layout based on the source of the visit to home page
  #
  def decide_layout
    @layout
  end

end
