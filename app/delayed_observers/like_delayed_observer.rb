class LikeDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(like_id)
    like = Like.with_user.find(like_id)
    Mailman.email_owner_about_a_like(like)
  end

end
