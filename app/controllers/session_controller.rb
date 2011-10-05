# Handle requests for the session lifecycle
#
class SessionController < ApplicationController

  # Display the login page
  #
  def new
  end

  #
  def create
    @service  = params[:service].to_sym
    @event    = params[:event].to_sym

    case @service 
    when :facebook

      case @event
      when :authenticate
        client              = FB_AUTH.client
        client.redirect_uri = fb_reply_url

        redirect_to client.authorization_uri(
                      :scope => [:email,:user_likes,
                                 :user_birthday,:publish_stream,
                                 :offline_access])
      when :reply
        if params[:code]
          client                    = FB_AUTH.client
          client.authorization_code = params[:code]
          access_token = client.access_token!

          if access_token
            fb_user = FbGraph::User.fetch("me?fields=first_name,last_name,"\
                                          "username,email,birthday",
                                            :access_token => access_token)
          end
        end
      else
        raise IOError, "Unknown event name"
      end
    else
      raise IOError, "Unknown service name"
    end

    if @user 
      self.current_user = @user
      set_cookie
      #redirect_to root_path
      #redirect_back_or_default root_path
    else
      redirect_to root_path
    end

  #rescue => ex
  #  handle_exception(ex)
  #ensure
  end

  # Delete the current session and remove all existing cookie
  # related data for the current user
  #
  def destroy
    self.current_user.forget if logged_in?
    delete_cookie
    reset_session

    redirect_to root_path
  rescue => ex
    handle_exception(ex)
  ensure
  end

end
