# Handle requests related to the followings resource
#
class FollowingsController < ApplicationController
  before_filter :login_required

  # Automatically add ifollowers for the current user from
  # a pre-selected pool
  #
  def new
    @users = Cache.fetch(KEYS[:to_follow_users]){User.to_follow}.shuffle[0..9]
    @followings = []

    @users.each do |user|
      @followings << Following.add(
                      user.id,
                      self.current_user.id,
                      'suggestion',
                      false)
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html
    end
  end

  # Create a new following from the current user towards
  # the given user
  #
  def create
    @following = Following.add(params[:user_id],self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Fetch the status of a following 
  #
  def show
    @following = Following.fetch(params[:id],self.current_user.id)
    @following = nil unless @following.present? && @following.is_active
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Destroy a following
  #
  def destroy
    following = Following.find(params[:id])
    following.remove if following.follower_id == self.current_user.id
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
