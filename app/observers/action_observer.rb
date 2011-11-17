# Observe events on the Action model
#
class ActionObserver < ActiveRecord::Observer

  # Alert notification manager about a new action
  #
  def after_create(action)
    ProcessingQueue.push(
      NotificationManager,
      :new_action,
      action.id)
  end

end
