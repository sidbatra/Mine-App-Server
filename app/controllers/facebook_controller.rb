class FacebookController < ApplicationController
  before_filter :create_client

  # Start the facebook authentication process.
  #
  def new
    @client.redirect_uri = fb_reply_url(
                            :src    => @source,
                            :target => params[:target],
                            :follow_user_id => params[:follow_user_id])

    target_url = @client.authorization_uri(
                  :scope => [:email,
                             :user_likes,
                             :user_birthday,
                             :publish_actions])

    target_url << '&display=touch' if is_phone_device?

    redirect_to target_url

  rescue => ex
    handle_exception(ex)
  end

  # Handle reply from facebook oaut.
  #
  def create
    follow_user_id  = params[:follow_user_id] 
    access_token    = params[:access_token]
    @target         = params[:target]          

    unless access_token
      @client.redirect_uri = fb_reply_url(
                              :src    => @source,
                              :target => @target,
                              :follow_user_id => params[:follow_user_id])

      @client.authorization_code = params[:code]
      access_token = @client.access_token!(:client_auth_body)
    end

    raise IOError, "Error fetching access token" unless access_token


    self.current_user.access_token = access_token.to_s
    self.current_user.save!
    #fb_user = FbGraph::User.fetch(
    #            "me?fields=first_name,last_name,"\
    #            "gender,email,birthday",
    #            :access_token => access_token)

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
