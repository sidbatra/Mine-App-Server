class CommentDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(comment_id)
    comment = Comment.find comment_id

    user_ids = Comment.user_ids_in_thread_with comment
    users = User.with_setting.find_all_by_id user_ids

    NotificationManager.new_comment comment,users
    Mailman.email_users_in_comment_thread comment,users
  end

end
