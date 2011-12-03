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

  # Set the mine_contacts flag to true whenever the
  # user's access_token changes and his/her facebook 
  # contacts haven't been mined yet
  #
  def before_update(user)
    user.mine_contacts = user.access_token_changed? && !user.has_contacts_mined
  end

  # Alert notification manager to mine contacts based on the 
  # flag set in before_update
  #
  def after_update(user)
    if user.mine_contacts
      ProcessingQueue.push(
        NotificationManager,
        :update_user,
        user.id) 
      user.mine_contacts = false
    end
  end

end
