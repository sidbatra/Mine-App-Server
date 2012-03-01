# Observe events on the Invite model
#
class InviteObserver < ActiveRecord::Observer

  # An invite is created
  #
  def after_create(invite)
    ProcessingQueue.push(
      InviteDelayedObserver,
      :after_create,
      invite.id)
  end

end
