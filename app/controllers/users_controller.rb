class UsersController < ApplicationController
  before_filter :login_required, :only => [:update]

  # Create a new user.
  #
  # The users/create url or its alias facebook/reply is a callback
  # url used by Facebook after a user has encountered a login with
  # fb dialog. If a valid access_token has been provided a new user
  # is created or an old one is fetched & it's fields updated.
  #
  # The flow is then redirected to onboarding or the user's feed
  # based on their status.
  #
  def create
    using = params[:using] ? params[:using].to_sym : :facebook

    case using
    when :facebook
      create_from_fb
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|

      format.html do
        set_cookie unless @error
        url = ""

        if @error
          url = root_path(:src => HomeShowSource::UserCreateError)
        elsif @user.is_fresh || @onboard
          url = welcome_path(WelcomeFilter::Learn) 
        elsif @target
          url = @target
        else
          url = root_path(:src => FeedShowSource::Login)
        end

        redirect_to url unless url == 'popup'
      end

      format.json
    end
  end

  # Display a user's profile.
  #
  def show
    if is_request_json?
      @user = User.find(Cryptography.deobfuscate params[:id])
    else
      track_visit

      @user = User.find_by_handle(params[:handle])
      @origin = 'user'
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  # Update a user. To ensure security only the currently logged
  # in user is updated and all updateable attributes are listed
  # in the User model.
  #
  def update

    @user = self.current_user
    @user.update_attributes(params)
  
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end


  protected

  # Use the OAuth token sent by Facebook to create a new user
  # or fetch and update an existing user.
  #
  def create_from_fb
    @target                   = params[:target]          
    access_token              = params[:access_token]

    unless access_token
      fb_auth                   = FbGraph::Auth.new(
                                    CONFIG[:fb_app_id],
                                    CONFIG[:fb_app_secret])

      client                    = fb_auth.client
      client.redirect_uri       = fb_reply_url(
                                    :src    => @source,
                                    :target => @target)
      client.authorization_code = params[:code]
      access_token              = client.access_token!(:client_auth_body)
    end

    raise IOError, "Error fetching access token" unless access_token


    fb_user = FbGraph::User.fetch(
                "me?fields=first_name,last_name,"\
                "gender,email,birthday",
                :access_token => access_token)

    @user   = User.add_from_fb(fb_user,@source)

    raise IOError, "Error creating user" unless @user

    setting = @user.setting
    setting.fb_publish_actions = true
    setting.save!

    @onboard = @user[:recreate]

    self.current_user = @user
  end

end
