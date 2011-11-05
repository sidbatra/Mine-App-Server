# Handle requests for the user resource
#
class UsersController < ApplicationController
  before_filter :login_required,  :only => :update
  before_filter :logged_in?,      :only => :show

  # Create a user based on token received from facebook
  #
  def create
    raise IOError, "User rejected FB connect" unless params[:code]

    source                    = params[:source] ? 
                                  params[:source].to_s : 
                                  "unknown"

    fb_auth                   = FbGraph::Auth.new(
                                  CONFIG[:fb_app_id],
                                  CONFIG[:fb_app_secret])

    client                    = fb_auth.client
    client.redirect_uri       = fb_reply_url(:source => source)
    client.authorization_code = params[:code]
    access_token              = client.access_token!

    raise IOError, "Error fetching access token" unless access_token


    fb_user = FbGraph::User.fetch("me?fields=first_name,last_name,"\
                                  "gender,email,birthday",
                                    :access_token => access_token)
    @user = User.add(fb_user,source)

    raise IOError, "Error creating user" unless @user


    self.current_user = @user
    set_cookie
    target_url = user_path(@user,:src => "login")

  rescue => ex
    handle_exception(ex)
    target_url = root_path(:src => "user_create_error")
  ensure
    redirect_to target_url
  end

  # Display user's profile
  #
  def show
    @source     = params[:src] ? params[:src].to_s : "direct"
    @category   = Category.get(params[:category]) 

    @user       = User.find(params[:id])
    @products   = Product.eager.for_user(
                            @user.id,
                            @category ? @category.id : "")

    @categories = Category.all
  end
  
  # Get user's iFollowers
  #
  def index
    @user = User.find(params[:id])

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
    @user.edit(params)
  
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
