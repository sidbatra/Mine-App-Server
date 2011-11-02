# Handle requests for the home page
#
class HomeController < ApplicationController
  before_filter :detect_origin
  layout        :decide_layout

  # Display pre-selected products on the home page
  #
  def show
    if params[:id]
      redirect_to root_path
    elsif logged_in? 
      redirect_to user_path(self.current_user,:src => "home_redirect") 
    else
      @layout = @origin == "home2" ? "home2" : "home1"
    end
  end

  private 

  # Decide layout based on the source of the visit to home page
  #
  def decide_layout
    @layout
  end

  # Detect which origin the user is coming from and save it to session
  #
  def detect_origin
    session[:origin]  ||= params[:id] ? params[:id].to_s : "direct"
    @origin             = session[:origin]
  end

end
