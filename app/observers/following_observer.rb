# Observe events on the Following model
#
class FollowingObserver < ActiveRecord::Observer

  # Increment counter cache value for user's followings_count
  # and follower's inverse following count
  #
  def after_create(following)
    increment_counter(following)

    ProcessingQueue.push(
      NotificationManager,
      :new_following,
      following.id) if following.send_email
  end

  # Decrement counter cache value for user's followings_count
  # and follower's inverse following count
  #
  def after_destroy(following)
    decrement_counter(following)
  end

  # Set is_active_toggled if the following is_active state has been
  # modified. This ensures that counter_caches are only updated
  # when a following state changes and not on other updates to
  # a following_model
  #
  def before_update(following)
    following.is_active_toggled = following.is_active_changed?
  end

  # Update the counter cache value for user's followings_count
  # and follower's inverse following count whenever a follow/unfollow
  # action takes place
  #
  def after_update(following)
    if following.is_active_toggled
      following.is_active ? 
        increment_counter(following) : 
        decrement_counter(following)
    end
  end

  # Increment counter_caches on the User mode
  #
  def increment_counter(following)
    User.increment_counter(:followings_count,following.user_id)
    User.increment_counter(:inverse_followings_count,following.follower_id) 
  end

  # Decrement counter_caches on the User mode
  #
  def decrement_counter(following)
    User.decrement_counter(:followings_count,following.user_id)
    User.decrement_counter(:inverse_followings_count,following.follower_id) 
  end

end
