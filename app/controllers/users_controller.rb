# Handle requests for the user resource
#
class UsersController < ApplicationController
  before_filter :login_required,  :only => :update
  before_filter :logged_in?,      :only => :show

  # Create a user based on token received from facebook
  #
  def create
    target                    = params[:target]          
    access_token              = params[:access_token]

    unless access_token
      fb_auth                   = FbGraph::Auth.new(
                                    CONFIG[:fb_app_id],
                                    CONFIG[:fb_app_secret])

      client                    = fb_auth.client
      client.redirect_uri       = fb_reply_url(
                                    :src    => @source,
                                    :target => target)
      client.authorization_code = params[:code]
      access_token              = client.access_token!
    end

    raise IOError, "Error fetching access token" unless access_token


    fb_user = FbGraph::User.fetch(
                "me?fields=first_name,last_name,"\
                "gender,email,birthday",
                :access_token => access_token)

    @user = User.add(fb_user,@source)

    raise IOError, "Error creating user" unless @user


    self.current_user = @user
    set_cookie
    target_url = @user.is_fresh ? 
                   welcome_path(WelcomeFilter::Learn) :
                   (target ? 
                    target : 
                    user_path(@user.handle,:src => UserShowSource::Login))

  rescue => ex
    handle_exception(ex)
    target_url = root_path(:src => HomeShowSource::UserCreateError)
  ensure
    redirect_to target_url
  end

  # Display user's profile
  #
  def show

    if params[:id].present?
      redirect_to user_path(User.find(params[:id]).handle)
      return
    end

    @user = User.find_by_handle(params[:handle])
  end
  
  # Fetch group of users based on different filters 
  #
  def index
    @filter   = params[:filter].to_sym

    case @filter
    when :followers
      @users      = User.find(params[:id]).followers
      @key        = KEYS[:user_followers] % params[:id]
    when :ifollowers
      @users      = User.find(params[:id]).ifollowers
      @key        = KEYS[:user_ifollowers] % params[:id]
    when :stars
      @achievers  = AchievementSet.current_star_users
      @key        = KEYS[:star_users]
    when :top_shoppers
      @achievers  = AchievementSet.current_top_shoppers(params[:store_id])
      @key        = KEYS[:store_top_shoppers] % params[:store_id]
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Update user's byline
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

end
