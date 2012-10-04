class FacebookController < ApplicationController
  before_filter :create_client

  # Start the facebook authentication process.
  #
  def new
    @target_url = root_path(:src => HomeShowSource::LoginError)

    @client.redirect_uri = fb_reply_url(
                            :src    => @source,
                            :target => params[:target],
                            :follow_user_id => params[:follow_user_id],
                            :usage  => params[:usage])

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

  # Handle reply from facebook oaut.
  #
  def create
    @usage = params[:usage] ? params[:usage].to_sym : :redirect
    access_token = params[:access_token]
    target = params[:target]
    follow_user_id = params[:follow_user_id]

    unless access_token
      @client.redirect_uri = fb_reply_url(
                              :src => @source,
                              :target => target,
                              :follow_user_id => follow_user_id,
                              :usage => params[:usage])

      @client.authorization_code = params[:code]
      access_token = @client.access_token!(:client_auth_body)
    end

    raise IOError, "Error fetching access token" unless access_token


    case @usage
    when :redirect
      redirect_to create_user_path(
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

  rescue => ex
    handle_exception(ex)
  end


  private

  # Create facebook client variable.
  #
  def create_client
    fb_auth = FbGraph::Auth.new(
                            CONFIG[:fb_app_id],
                            CONFIG[:fb_app_secret])

    @client = fb_auth.client
  end
end
