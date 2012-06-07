class LikeObserver < ActiveRecord::Observer

  # Hand off email notification to like delayed observers.
  #
  def after_create(like)
    ProcessingQueue.push(
      LikeDelayedObserver,
      :after_create,
      like.id)
  end

end
