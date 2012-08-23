class FacebookController < ApplicationController
  before_filter :create_client

  # Start the facebook authentication process.
  #
  def new
    @client.redirect_uri = fb_reply_url(
                            :src    => @source,
                            :target => params[:target],
                            :follow_user_id => params[:follow_user_id],
                            :usage  => params[:usage])

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
    target          = params[:target]          
    @usage          = params[:usage] ? params[:usage].to_sym : :redirect

    unless access_token
      @client.redirect_uri = fb_reply_url(
                              :src    => @source,
                              :target => target,
                              :follow_user_id => follow_user_id,
                              :usage => params[:usage])

      @client.authorization_code = params[:code]
      access_token = @client.access_token!(:client_auth_body)
    end

    raise IOError, "Error fetching access token" unless access_token


    case @usage
    when :redirect
      fb_user = FbGraph::User.fetch(
                  "me?fields=first_name,last_name,"\
                  "gender,email,birthday",
                  :access_token => access_token)

      user = User.find_by_fb_user_id fb_user.identifier

      if user
        user.access_token = access_token.to_s
        user.save!

        session[:user_id] = user.id

        redirect_to enter_path(
                      :target => target,
                      :follow_user_id => follow_user_id)
      else
        redirect_to create_user_path(
                      'user[fb_user_id]' => fb_user.identifier,
                      'user[email]' => fb_user.email,
                      'user[gender]' => fb_user.gender,
                      'user[birthday]' => fb_user.birthday,
                      'user[first_name]' => fb_user.first_name,
                      'user[last_name]' => fb_user.last_name,
                      'user[access_token]' => access_token.to_s,
                      'user[source]' => @source,
                      :follow_user_id => follow_user_id)
      end

    when :popup
      self.current_user.access_token = access_token.to_s
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
