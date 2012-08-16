class FollowingsController < ApplicationController
  before_filter :login_required

  # Create a new following from the current user towards
  # the given user.
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

  # Return all active followings of the current user.
  #
  def index
    @followings = Following.active.all(
                    :conditions => {:follower_id => self.current_user.id})
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Fetch the status of a following.
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

  # Destroy a following.
  #
  def destroy
    @following = Following.find(params[:id])
    @following.remove if @following.follower_id == self.current_user.id
    @following = nil
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
