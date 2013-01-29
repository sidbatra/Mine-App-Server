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
      base.send :helper_method, :is_tablet_device?, :is_mobile_device?, 
                :is_android_tablet_device?, :is_device?, :is_phone_device?, 
                :is_device_ipad?, :is_ie?, :is_device_iphone?
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
      log_exception(ex,logged_in? ? "user: #{self.current_user.handle}" : '')
      @error    = true
      @message  = ex.message
    end

    # Override rescue action to log 404 errors
    # 
    def rescue_action_in_public(exception)
      case exception
        when ActiveRecord::RecordNotFound, ActionController::RoutingError, 
              ActionController::UnknownController, 
              ActionController::UnknownAction
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
          render :file => "#{RAILS_ROOT}/public/404.html", 
            :status => :not_found 
        end
      end
    end

    #----------------------------------------------------------------------
    # Device related queries
    #----------------------------------------------------------------------

    # Test if the current request is from a mobile device
    #
    def is_mobile_device?
      request.user_agent.to_s.downcase =~ 
        Regexp.new(CONFIG[:mobile_user_agents])
    end

    # Test if the current request is from an android tablet.
    #
    def is_android_tablet_device?
      agent = request.user_agent.to_s
      agent =~ /Android/ && agent !~ /Mobile/
    end

    # Test if the current request is from a tablet device.
    #
    def is_tablet_device?
      request.user_agent.to_s.downcase =~ 
        Regexp.new(CONFIG[:tablet_user_agents]) || is_android_tablet_device?
    end

    # Test if the current request is from a mobile phone.
    #
    def is_phone_device?
      is_mobile_device? && !is_tablet_device?
    end

    # Test if the current request is from a specific device
    #
    def is_device?(device)
      request.user_agent.to_s.downcase.include?(device.to_s.downcase)
    end

    # Test if the current device is an iphone
    #
    def is_device_iphone?
      @is_device_iphone ||= is_device?('iphone')
    end

    # Test if the current device is an ipad
    #
    def is_device_ipad?
      @is_device_ipad ||= is_device?('ipad')
    end

    #----------------------------------------------------------------------
    # Browser related queries
    #----------------------------------------------------------------------

    # Test if the current browser is IE.
    #
    def is_ie?
      request.user_agent.to_s =~ /MSIE/ && request.user_agent.to_s !~ /Opera/
    end

  end

end #dw
