# Handle user related requests for admin view
#
class Admin::UsersController < ApplicationController
  before_filter :admin_required

  # Fetch sets of users based on different filters
  # 
  def index 
    @filter = params[:filter].to_sym

    case @filter
    when :active
      @users = {}
      @users['daily']     = active_users_in_time_period(1.day.ago)
      @users['weekly']    = active_users_in_time_period(1.week.ago)
      @users['biweekly']  = active_users_in_time_period(15.days.ago)
      @users['monthly']   = active_users_in_time_period(1.month.ago)
    end

    render :partial => @filter.to_s,
           :layout  => "application"
  end


  # Display the user's queries and products. 
  #
  def show
    @user       = User.find_by_handle(params[:id])
    @collection = (@user.searches + @user.products).sort{
                   |x,y| x.created_at <=> y.created_at}
  end

  # Destroy the user
  #
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    sleep 10
    Mailman.user_deleted(@user)

    redirect_to admin_path
  end

  protected

  # Fetch users who have been active in the given time period
  #
  def active_users_in_time_period(time)
    user_ids = [Product,Action,Collection,Comment].map do |model|
                 model.select(:user_id).made(time).map(&:user_id)
               end.flatten.uniq

    User.find_all_by_id(user_ids)
  end


end
