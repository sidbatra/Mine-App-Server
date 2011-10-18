# Observe events on the Comment model
#
class CommentObserver < ActiveRecord::Observer

  # Alert notification manager about a new comment
  #
  def after_create(comment)
    ProcessingQueue.push(
      NotificationManager,
      :new_comment,
      comment.id)
  end

end
