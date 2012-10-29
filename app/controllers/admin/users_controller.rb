# Handle user related requests for admin view
#
class Admin::UsersController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  # Fetch sets of users based on different filters
  # 
  def index 

    case params[:filter].to_sym
    when :active
      @period = params[:period].to_sym
      @time = 1.day.ago

      case @period
      when :daily
        @time = 1.day.ago
      when :weekly
        @time = 1.week.ago
      when :biweekly
        @time = 15.days.ago
      when :monthly
        @time = 1.month.ago
      end

      @users,@active_count = active_users_in_time_period(@time)
      @view = "active"
    end

    render @view
  end


  # Display the user's queries and purchases. 
  #
  def show
    @user = User.find_by_handle(params[:id])
    @set  = (@user.searches.for(SearchSource::New) + @user.purchases).sort do |x,y| 
              x.created_at <=> y.created_at
            end
  end

  def edit
    @user = User.find_by_handle params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.generate_handle = true

    params[:user][:email] = nil if params[:user][:email].empty?
    params[:user][:fb_user_id] = nil if params[:user][:fb_user_id].empty?
    params[:user][:tw_user_id] = nil if params[:user][:tw_user_id].empty?

    @user.update_attributes params[:user]

    if params[:become]
      self.current_user = @user
    end

    redirect_to edit_admin_user_path(@user.handle)
  end

  # Destroy the user
  #
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    sleep 10
    Mailman.email_admin_about_deleted_user(@user)

    redirect_to admin_path
  end


  protected

  # Fetch users who have been active in the given time period
  #
  def active_users_in_time_period(time)
    active_count = [Purchase,Search,Like,Comment].map do |model|
                         model.select(:user_id).made(time).map(&:user_id)
                       end.flatten.uniq.count

    [User.visited(time).by_visited_at,active_count]
  end


end
