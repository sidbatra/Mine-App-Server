class CommentDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(comment_id)
    comment = Comment.with_user.find(comment_id)
    Mailman.email_users_in_comment_thread(comment)
  end

end
