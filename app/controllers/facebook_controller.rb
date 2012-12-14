class FacebookController < ApplicationController
  before_filter :create_client

  # Start the facebook authentication process.
  #
  def new
    @target_url = root_path(:src => HomeShowSource::LoginError)

    session[:fb_redirect_uri] = fb_reply_url(
                                  :src    => @source,
                                  :target => params[:target],
                                  :follow_user_id => params[:follow_user_id],
                                  :usage  => params[:usage])

    @client.redirect_uri = session[:fb_redirect_uri]

    @target_url = @client.authorization_uri(
                  :scope => [:email,
                             :user_likes,
                             :user_birthday,
                             :publish_actions])

    @target_url << '&display=touch' if is_phone_device?

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to @target_url
  end

  # Handle reply from facebook oauth.
  #
  def create
    @usage = params[:usage] ? params[:usage].to_sym : :redirect
    access_token = params[:access_token]
    target = params[:target]
    follow_user_id = params[:follow_user_id]

    if !access_token && params[:code]
      @client.redirect_uri = session[:fb_redirect_uri]
      @client.authorization_code = params[:code]

      access_token = @client.access_token!(:client_auth_body)
    end

    if access_token
      case @usage
      when :redirect
        @target_url = create_user_path(
                        :using => "facebook",
                        :access_token => access_token,
                        :target => target,
                        :src => @source,
                        :follow_user_id => follow_user_id)

      when :popup
        fb_user = FbGraph::User.fetch("me?fields=id",
                    :access_token => access_token)

        self.current_user.access_token = access_token.to_s
        self.current_user.fb_user_id = fb_user.identifier
        self.current_user.save!
      end
    else
      @error = true
    end

  rescue => ex
    handle_exception(ex)
  ensure
    case @usage
    when :redirect
      redirect_to @error ? 
        root_path(:src => HomeShowSource::FBDenied) : 
        @target_url
    end
  end


  private

  # Create facebook client variable.
  #
  def create_client
    fb_auth = FbGraph::Auth.new(
                            CONFIG[:fb_app_id],
                            CONFIG[:fb_app_secret],
                            :redirect_uri => session[:fb_redirect_uri])

    @client = fb_auth.client
  end
end
