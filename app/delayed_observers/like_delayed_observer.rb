class LikeDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(like_id)
    like = Like.find like_id

    if like.user_id != like.purchase.user_id
      NotificationManager.new_like like
      Mailman.email_owner_about_a_like like
    end
  end

end
