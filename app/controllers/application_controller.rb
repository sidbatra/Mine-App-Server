# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#
class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
  filter_parameter_logging :password, :secret 
  before_filter :populate_categories, :track_source


  include ExceptionLoggable, DW::AuthenticationSystem, DW::RequestManagement

  protected

  # Popular categories for the drop down in the header
  #
  def populate_categories
    @categories = Category.fetch_all if @controller != :home && !is_json?
  end

  # Populate the source variable for analytics before
  # every request
  #
  def track_source
    @source       = params[:src] ? params[:src].to_s : 'direct'
  end

  # Test is the format of the current request is json
  #
  def is_json?
    request.format == Mime::JSON
  end

end

