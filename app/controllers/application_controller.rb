# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#
class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
  filter_parameter_logging :password, :secret 
  before_filter :populate_categories


  include ExceptionLoggable, DW::AuthenticationSystem, DW::RequestManagement

  protected

  # Popular categories for the drop down in the header
  #
  def populate_categories
    @categories = Category.fetch_all if logged_in?
  end

end

