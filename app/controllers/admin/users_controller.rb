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
      @buckets = [{:time => 1.day.ago,  :name => 'daily'},
                  {:time => 1.week.ago, :name => 'weekly'},
                  {:time => 15.days.ago,:name => 'biweekly'},
                  {:time => 1.month.ago,:name => 'monthly'}]

      @buckets.each do |bucket|
        bucket[:users],
        bucket[:count],
        bucket[:active_count] = active_users_in_time_period(bucket[:time])
      end
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
    Mailman.email_admin_about_deleted_user(@user)

    redirect_to admin_path
  end


  protected

  # Fetch users who have been active in the given time period
  #
  def active_users_in_time_period(time)
    count = User.updated(time).by_updated_at.count
    users = User.updated(time).by_updated_at.limit(150)

    active_count = [Product,Action,Collection,
                      Comment,Search].map do |model|
                     model.select(:user_id).made(time).map(&:user_id)
                   end.flatten.uniq.count

    [users,count,active_count]
  end


end
