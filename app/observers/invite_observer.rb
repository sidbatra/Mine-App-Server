class InviteObserver < ActiveRecord::Observer

  # Hand off processing to invite delayed observers.
  #
  def after_create(invite)
    #ProcessingQueue.push(
    #  InviteDelayedObserver,
    #  :after_create,
    #  invite.id)
  end

end
