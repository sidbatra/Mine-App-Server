# Handle requests for the user resource
#
class UsersController < ApplicationController
  before_filter :login_required,  :only => :update
  before_filter :renew_session, :only => :show

  # Create a user based on token received from facebook
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
        url = ""

        if @error
          url = root_path(:src => HomeShowSource::UserCreateError)
        elsif @user.is_fresh || @onboard
          url = welcome_path(WelcomeFilter::Learn) 
        elsif @target
          url = @target
        else
          url = user_path(@user.handle,:src => UserShowSource::Login)
        end

        redirect_to url
      end

      format.json
    end
  end

  # Display user's profile
  #
  def show

    if params[:id].present?
      redirect_to user_path(User.find(params[:id]).handle)
      return
    end

    @user = User.find_by_handle(params[:handle])
    @styles = CONFIG[:styles]
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
      @users      = User.find(params[:id]).ifollowers.by_updated_at
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


  protected

  # Create current user via fb oauth
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
      access_token              = client.access_token!
    end

    raise IOError, "Error fetching access token" unless access_token


    fb_user = FbGraph::User.fetch(
                "me?fields=first_name,last_name,"\
                "gender,email,birthday",
                :access_token => access_token)

    @user = User.add_from_fb(fb_user,@source)

    raise IOError, "Error creating user" unless @user

    @onboard = @user[:recreate]

    self.current_user = @user
    set_cookie
  end

end
