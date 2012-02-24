# Handle all requests for static pages 
#
class StaticController < ApplicationController

  # Render different static pages based on filters
  #
  def show
    @filter = params[:filter].to_s
    
    render :partial => @filter,
           :layout  => "application"

  end
end
