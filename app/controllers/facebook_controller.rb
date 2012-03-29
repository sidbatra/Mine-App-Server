# Handle requests for all facebook related resources
#
class FacebookController < ApplicationController
  
  # Handle facebook related get requests for real time updates 
  #
  def index
    @filter = params[:filter].to_sym
  
    case @filter
    when :subscriptions
    end
  end 

  # Handle facebook related post requests for real time updates 
  #
  def create
    @filter = params[:filter].to_sym
  
    case @filter
    when :subscriptions
    end
  end

end
