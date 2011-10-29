# Observe events on the User model
#
class UserObserver < ActiveRecord::Observer

  # Alert notification manager about a new user 
  #
  def after_create(user)
    ProcessingQueue.push(
      NotificationManager,
      :new_user,
      user.id)
  end

end
