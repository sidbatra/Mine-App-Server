class FollowingDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(following_id)
    following = Following.find(following_id)
    Mailman.email_leader_about_follower(following)
  end

end
