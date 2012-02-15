# Handle requests for the home page
#
class HomeController < ApplicationController
  before_filter :detect_origin
  layout        'home'

  # Display pre-selected products on the home page
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

  # Detect which origin the user is coming from and save it to session
  #
  def detect_origin
    session[:home]    = 'path' #['art','zendesk','gojee','gojee1'][rand(4)]
    session[:origin]  ||= params[:id] ? params[:id].to_s : 'direct'
    @home               = session[:home]
    @campaign           = session[:origin]
    @origin             = session[:origin] + '_' + @home
  end

end
