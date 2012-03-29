# Handle requests for all facebook related resources
#
class FacebookController < ApplicationController
  
  # Handle facebook related get requests for real time updates 
  #
  def index
    @filter = params[:filter].to_sym
  
    case @filter
    when :subscriptions
      mode          = params['hub.mode']
      challenge     = params['hub.challenge']
      verify_token  = params['hub.verify_token']

      unless mode && challenge && verify_token == CONFIG[:fb_verify_token] 
        raise IOError, "Incorrect params for fb subscription verification" 
      end

    else
      raise IOError, "Incorrect facebook index filter"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end 

  # Handle facebook related post requests for real time updates 
  #
  def create
    @filter = params[:filter].to_sym
  
    case @filter
    when :subscriptions
    else
      raise IOError, "Incorrect facebook create filter"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
