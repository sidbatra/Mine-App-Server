module DW

  # Mixin module for the application controller. Provides the view and 
  # controller helper methods to query information about the request
  # Also enables controlling the flow of the request
  #
  module RequestManagement

    protected

    # Inclusion hook to add helper methods
    #
    def self.included(base)
      base.send :helper_method, :is_mobile_device?, :is_device?,
                  :is_device_iphone?, :is_device_ipad?
    end

    # Preprocess every request 
    # Create variables for params such as email,password,pagination.
    #
    def preprocess_request

      unless params[:email].json_nil
        @email      = params[:email] 
      end

      if !is_request_html? && !params[:password].json_nil
        @password   = Cryptography.decrypt(params[:password]) 
      else
        @password   = params[:password]
      end

      if params[:hashed_id]
        params[:id] = Cryptography.deobfuscate(params[:hashed_id]) 
      end

      @before   = !params[:before].zero ? Time.at(params[:before].to_i) : nil
      @after    = !params[:after].zero  ? Time.at(params[:after].to_i)  : nil 
      @limit    = !params[:limit].zero  ? params[:limit].to_i           : nil
    end

    # Tests if the request has an JSON mime type
    #
    def is_request_json?
      request.format == Mime::JSON
    end
    # Tests if the request has an JS mime type
    #
    def is_request_js?
      request.format == Mime::JS
    end

    # Tests if the request has an HTML mime type
    #
    def is_request_html?
      request.format == Mime::HTML
    end

    # Handle the exception by logging it and setting up
    # variables that contain error information
    #
    def handle_exception(ex)
      log_exception(ex)
      @error    = true
      @message  = ex.message
    end

    # Override rescue action to log 404 errors
    # 
    def rescue_action_in_public(exception)
      case exception
        when ActiveRecord::RecordNotFound, ActionController::RoutingError, 
              ActionController::UnknownController, ActionController::UnknownAction
          log_exception(exception)
          render :file => "#{RAILS_ROOT}/public/404.html"
        else
          super
      end
    end

    # Render the 404 page
    #
    def render_404
      respond_to do |format|
        format.html do 
          render :file => "#{RAILS_ROOT}/public/404.html", :status => :not_found 
        end
      end
    end

    #-----------------------------------------------------------------------------
    # Device related queries
    #-----------------------------------------------------------------------------

    # Test is the current request is from a mobile device
    #
    def is_mobile_device?
      request.user_agent.to_s.downcase =~ 
        Regexp.new(CONFIG[:mobile_user_agents])
    end

    # Test is the current request is from a specific device
    #
    def is_device?(device)
      request.user_agent.to_s.downcase.include?(device.to_s.downcase)
    end

    # Test if the current device is an iphone
    #
    def is_device_iphone?
      @is_device_ihone ||= is_device?('iphone')
    end

    # Test if the current device is an ipad
    #
    def is_device_ipad?
      @is_device_ipad ||= is_device?('ipad')
    end

  end

end #dw
