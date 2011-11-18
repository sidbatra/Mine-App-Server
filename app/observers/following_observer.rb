# Observe events on the Following model
#
class FollowingObserver < ActiveRecord::Observer

  # Increment counter cache value for user's followings_count
  # and follower's inverse following count
  #
  def after_create(following)
    User.increment_counter(:followings_count,following.user_id)
    User.increment_counter(:inverse_followings_count,following.follower_id)

    ProcessingQueue.push(
      NotificationManager,
      :new_following,
      following.id) if following.send_email
  end

  # Decrement counter cache value for user's followings_count
  # and follower's inverse following count
  #
  def after_destroy(following)
    User.decrement_counter(:followings_count,following.user_id)
    User.decrement_counter(:inverse_followings_count,following.follower_id)
  end

  # Update the counter cache value for user's followings_count
  # and follower's inverse following count whenever a follow/unfollow
  # action takes place
  #
  def after_update(following)
    if following.is_active
      User.increment_counter(:followings_count,following.user_id)
      User.increment_counter(:inverse_followings_count,following.follower_id) 
    else
      User.decrement_counter(:followings_count,following.user_id)
      User.decrement_counter(:inverse_followings_count,following.follower_id) 
    end
  end

end
