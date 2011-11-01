# Handle requests for the home page
#
class HomeController < ApplicationController
layout :decide_layout

  # Display pre-selected products on the home page
  #
  def show
    @origin   = params[:id] ? params[:id].to_s : "direct"
    @source   = params[:src] ? params[:src].to_s : "direct"
    @layout   = "home1"
    @layout   = "home2" if @origin == "home2"

  
    page = "show1"
    page = "show2" if @origin == "home2"

    if logged_in? 
      redirect_to user_path(self.current_user,:src => "home_redirect") 
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
