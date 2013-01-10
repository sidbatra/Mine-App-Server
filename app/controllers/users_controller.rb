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
    target = params[:target]          
    follow_user_id = params[:follow_user_id] 

    case using
    when :facebook
      create_from_fb
    when :twitter
      create_from_tw
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|

      format.html do
        if @user && !@error
          self.current_user = @user
          set_cookie 
          Following.add(follow_user_id,self.current_user.id,FollowingSource::Auto,false) if follow_user_id

          if session[:invited_by_user_id]
            Following.add(session[:invited_by_user_id],self.current_user.id,FollowingSource::Auto,false) 
            Following.add(self.current_user.id,session[:invited_by_user_id],FollowingSource::Auto,false) 
          end
        end

        url = ""

        if @error
          url = root_path(:src => HomeShowSource::UserCreateError)
        elsif !@user.email.present? || !@user.gender.present?
          url = welcome_path(WelcomeFilter::Info)
        elsif @user.is_fresh 
          url = welcome_path(WelcomeFilter::Connect) 
        elsif target
          url = target
        else
          url = root_path(:src => FeedShowSource::Login)
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
                      with(:followers,self.current_user.ifollower_ids)
                    end unless self.current_user.inverse_followings_count.zero?
                  end
                end  
                without(:followers,self.current_user.id) if params[:skip_followers]
                paginate :per_page => 5
               end.results unless fragment_exist?(@key)

      Search.add(
        {:query => query,:source => SearchSource::User},
        self.current_user.id)

    when :connections
      @user = User.find_by_handle params[:handle]
      @origin = "connections"
      @view = "connections"
      populate_theme @user if @user

    when :suggestions
      @view = "suggestions"
      @user = self.current_user
      ifollower_ids = self.current_user.ifollower_ids 
      per_page = params[:per_page] ? params[:per_page].to_i : 3

      followings = Following.find_all_by_follower_id(
                    ifollower_ids,
                    :conditions => ["user_id not in (?) AND U.has_purchases_mined = 1 AND U.purchases_count > 2 AND is_active = true", ifollower_ids + [self.current_user.id]],
                    :joins      => 'INNER JOIN users ON users.id = followings.follower_id INNER JOIN users as U ON U.id = followings.user_id',
                    :group      => :user_id,
                    :include    => :user,
                    :select     => 'followings.*,
                                    GROUP_CONCAT(CONCAT_WS(\' \', users.first_name, users.last_name)) AS FOLLOWED_BY',
                    :order      => 'RAND()',
                    :limit      => per_page * 0.667)
          
      @users = followings.each do |f|
                 f.user['message'] = follow_message(f['FOLLOWED_BY'],params[:mobile])
               end.map(&:user)
      
      @users += User.find_all_by_is_special(
                      true,
                      :conditions => ["id not in (?)", followings.map(&:user_id) + ifollower_ids + [self.current_user.id]],
                      :order => 'RAND()',
                      :limit => per_page - @users.size).each{|u| u['message'] = u.byline}
    end

  rescue => ex
    handle_exception(ex)
  ensure
    raise_not_found if @aspect == :connections && !@user

    respond_to do |format|
      format.html do
        track_visit
        render @view
      end
      format.json
    end
  end

  # Display a user's profile.
  #
  def show
    if is_request_json?
      @user = User.find_by_id Cryptography.deobfuscate(params[:id])
    else
      track_visit

      if @user = User.find_by_handle(params[:handle])
        @following = Following.fetch @user.id,self.current_user.id
        @origin = 'user'

        populate_theme @user 
      end
    end

  rescue => ex
    handle_exception(ex)
  ensure
    raise_not_found unless @user

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
    @user.reload
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
    fb_user = FbGraph::User.fetch(
                "me?fields=first_name,last_name,"\
                "gender,email,birthday",
                :access_token => params[:access_token])

    @user = User.add_from_fb(fb_user,@source)
  end

  # Use the Oauth tokens from Twitter to create a new user
  # or fetch and update an existing user.
  #
  def create_from_tw
    client = Twitter::Client.new(
                  :consumer_key => CONFIG[:tw_consumer_key],
                  :consumer_secret => CONFIG[:tw_consumer_secret],
                  :oauth_token => params[:tw_access_token],
                  :oauth_token_secret => params[:tw_access_token_secret])

    @user = User.add_from_tw(
                  client.user,
                  params[:tw_access_token],
                  params[:tw_access_token_secret],
                  @source)
  end

  # Generate a message for the user that we recommend to follow
  #
  def follow_message(users,mobile)
    users = users.split(',')

    message = "Followed by "

    if mobile
      message << users.first
    else
      if users.length <= 2
        message << users[0..1].join(" and ")
      elsif users.length == 3
        message << users[0..1].join(", ") + " and 1 other"   
      else
        message << users[0..1].join(", ") + " and #{users.length - 2} others"   
      end
    end
    
  end

end
