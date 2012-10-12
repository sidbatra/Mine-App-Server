class FollowingDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(following_id)
    following = Following.find following_id

    NotificationManager.new_following following
    Mailman.email_leader_about_follower following
  end

end
