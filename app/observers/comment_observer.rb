class CommentObserver < ActiveRecord::Observer

  # Hand off email notification to comment delayed observers.
  #
  def after_create(comment)
    ProcessingQueue.push(
      CommentDelayedObserver,
      :after_create,
      comment.id)
  end

end
