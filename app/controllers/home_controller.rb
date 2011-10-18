# Handle requests for the home page
#
class HomeController < ApplicationController

  # Display pre-selected products on the home page
  #
  def show
    @source    = params[:id] ? params[:id].to_s : "unknown"
  end

end
