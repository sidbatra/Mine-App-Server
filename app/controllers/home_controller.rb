class HomeController < ApplicationController
  before_filter :detect_origin
  layout        'home'

  # Display the home page.
  #
  def show
    if params[:id]
      redirect_to root_path
    elsif logged_in? 
      redirect_to user_path(
                    self.current_user.handle,
                    :src => UserShowSource::HomeRedirect)
    end
  end

  private 

  # Detect and store various tracking variables inside the session
  # and the curent request.
  #
  def detect_origin
    session[:home]    ||= 'bootstrap'
    session[:origin]  ||= params[:id] ? params[:id].to_s : 'direct'
    @home               = session[:home]
    @campaign           = session[:origin]
    @origin             = session[:origin] + '_' + @home
  end

end
