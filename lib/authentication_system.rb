module DW

  # Provides application wide helper methods for handling user
  # authentication
  #
  module AuthenticationSystem
    protected

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    #
    def logged_in?
      current_user != :false 
    end

    # Accesses the current user from the session.
    #
    def current_user
      @current_user ||= (session[:user] && User.find_by_id(session[:user])) || 
                        login_from_client ||
                        login_from_cookie || 
                        :false
    end

    # Store the given user in the session.
    #
    def current_user=(new_user)
      session[:user]  = new_user.nil? || new_user.is_a?(Symbol) ? 
                          nil : 
                          new_user.id
      @current_user   = new_user
    end

    # Test if the given user is the current user
    #
    def is_current_user(user)
      logged_in? && @current_user.id == user.id
    end
    
    # Filter method to enforce a login requirement.
    #
    def login_required
      logged_in? ? true : access_denied
    end

    # Filter method to enforce admin only pages
    #
    def admin_required
      self.current_user != :false && 
                        self.current_user.is_admin? ? true : access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    def access_denied
      store_location
      redirect_to root_path(:target => request.request_uri)
      #respond_to do |format|
      #  format.json do
      #    render :partial => "json/response",
      #           :locals  => {
      #              :success  => false,
      #              :message  => "Authorization Required",
      #              :body     => nil}
      #  end
      #  format.html do 
      #    redirect_to root_path#(:after_login => request.request_uri)
      #  end
      #end
    end  
    
    # Store the URI of the current request in the session.
    #
    def store_location
      session[:redirect_after_login] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    #
    def redirect_back_or_default(default)
      session[:redirect_after_login] ? 
        redirect_to(session[:redirect_after_login]) : 
        redirect_to(default)

      session[:redirect_after_login] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :is_current_user,
        :set_cookie, :delete_cookie, :login_required, 
        :admin_required, :access_denied
    end

    # Tests the predefined auth_* params to see if the request is signed and 
    # coming from a valid client on behalf of a user.
    #
    def login_from_client
      return nil unless params[:auth_client] && 
                        params[:auth_client] == "iphone" &&
                        params[:auth_id] &&
                        params[:auth_secret] 

      auth_secret_index = request.url =~ /&auth_secret/
      signature = Digest::MD5.hexdigest "--#{CONFIG[:iphone_salt]}"\
                    "--#{request.url.slice(0,auth_secret_index)}"

      return nil unless signature == params[:auth_secret].downcase || /\/auth/ === request.url

      User.find Cryptography.deobfuscate(params[:auth_id])
    rescue
      nil
    end

    # When called with before_filter :login_from_cookie will check 
    # for an :auth_token cookie and log the user back in if appropiate
    #
    def login_from_cookie
      if cookies[:auth_token] 
        user = User.find_by_cookie(cookies[:auth_token])

        # is a user found and is the cookie still valid
        if user && user.remember_token?
          self.current_user = user
        end
      end
    end
     
    # Save a cookie for the current user
    #
    def set_cookie
        self.current_user.remember
        cookies[:auth_token] = { 
          :value    => self.current_user.remember_token, 
          :expires  => self.current_user.remember_token_expires_at }
    end

    # Delete the cookie for the current user
    #
    def delete_cookie
      cookies.delete :auth_token
    end

  end

end #DW
