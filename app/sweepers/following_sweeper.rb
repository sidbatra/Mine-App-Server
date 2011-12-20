# Observer events on the following model to keep 
# following related cache stores persistent
#
class FollowingSweeper < ActionController::Caching::Sweeper
  observe Following

  # Fired when a following is created
  #
  def after_create(following)
    expire_followers(following)
    expire_ifollowers(following)
  end

  # Fired when a following is updated
  #
  def after_update(following)
    if(following.is_active_toggled)
      expire_followers(following)
      expire_ifollowers(following)
    end
  end

  # Fired when a following is destroyed
  #
  def after_destroy(following)
    expire_followers(following)
    expire_ifollowers(following)
  end

  # Expire followers for the user who is being followed
  #
  def expire_followers(following)
    expire_cache(KEYS[:user_followers] % following.user_id)
  end

  # Expire ifollowers for the user who created the following
  #
  def expire_ifollowers(following)
    expire_cache(KEYS[:user_ifollowers] % following.follower_id)
  end
end
