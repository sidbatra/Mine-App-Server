# Observe events on the Following model
#
class FollowingObserver < ActiveRecord::Observer

  # Increment counter cache value for user's 
  # followers and following count.
  #
  def after_create(following)
    user_id = following.user_id

    User.increment_counter(:followings_count,user_id)
    User.increment_counter(:inverse_followings_count,user_id)

    ProcessingQueue.push(
      NotificationManager,
      :new_following,
      following.id) if following.send_email
  end

  # Decrement counter cache value for user's 
  # followers and following count.
  #
  def after_destroy(following)
    user_id = following.user_id

    User.decrement_counter(:followings_count,user_id)
    User.decrement_counter(:inverse_followings_count,user_id)
  end

end
