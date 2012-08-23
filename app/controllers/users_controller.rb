class UsersController < ApplicationController
  before_filter :login_required, :only => [:update]

  # Create a new user.
  #
  def create
    follow_user_id = params[:follow_user_id] 

    if params[:user][:fb_user_id]
      @user = User.find_by_fb_user_id params[:user][:fb_user_id]
    elsif params[:user][:tw_user_id]
      @user = User.find_by_tw_user_id params[:user][:tw_user_id]
    end

    @user = User.create params[:user] unless @user
    
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|

      format.html do
        if @user && !@error
          self.current_user = @user
          Following.add(follow_user_id,self.current_user.id) if follow_user_id
          set_cookie 
        end

        url = ""

        if @error
          url = root_path(:src => HomeShowSource::UserCreateError)
        else
          url = welcome_path(WelcomeFilter::Learn) 
        end

        redirect_to url 
      end

      format.json
    end
  end

  # List of users with the following aspects.
  #
  # params[:aspect]:
  #   likers  - requires params[:purchase_id]. All users
  #               who've liked the given purchase.
  #   followers - requires params[:user_id]. All users
  #                 who follow the given user.
  #   ifollowers - requires params[:user_id]. All users
  #                 which the given user follows.
  #   search - requires params[:query]. params[:skip_followers]
  #             can be used to customize results.
  #
  def index
    @aspect = params[:aspect].to_sym
    @users = []
    @key = ""
    @cache_options = {}

    case @aspect
    when :likers
      purchase = Purchase.with_likes.find params[:purchase_id]
      @users = purchase.likes.map(&:user)
      @key = ["v1",purchase,@users.map(&:updated_at).max.to_i, "likers"]

    when :followers
      user = params[:handle] ? 
              User.find_by_handle(params[:handle]) :
              User.find(params[:user_id])
      @users = user.followers
      @key = ["v1",user,@users.map(&:updated_at).max.to_i, "followers"]

    when :ifollowers
      user = params[:handle] ? 
              User.find_by_handle(params[:handle]) :
              User.find(params[:user_id])
      @users = user.ifollowers
      @key = ["v1",user,@users.map(&:updated_at).max.to_i, "ifollowers"]

    when :search
      query = params[:q]
      @key = ["v1",self.current_user,Base64.encode64(query).gsub("\n","")[0..99]]
      @cache_options = {:expires_in => 1.minute}
      @users = User.search do 
                fulltext query do 
                  unless params[:skip_followers]
                    boost(10) do 
                      with(:followers,self.current_user.id)
                    end 
                    boost(5) do 
                      with(:followers,self.current_user.follower_ids)
                    end 
                  end
                end  
                without(:followers,self.current_user.id) if params[:skip_followers]
                paginate :per_page => 5
               end.results unless fragment_exist?(@key)

    when :connections
      @user = User.find_by_handle params[:handle]
      @origin = "connections"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do
        track_visit
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
      @following = Following.fetch @user.id,self.current_user.id
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

end
