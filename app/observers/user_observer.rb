# Observe events on the User model
#
class UserObserver < ActiveRecord::Observer

  # Fired before a user is created
  #
  def before_create(user)
    user.build_setting  
  end

  # Alert notification manager about a new user 
  #
  def after_create(user)
    ProcessingQueue.push(
      UserDelayedObserver,
      :after_create,
      user.id) if user.is_registered?
  end

  # Set flags to be used in after_update before an update finishes
  #
  def before_update(user)
    user[:recreate] = user.access_token_was.nil? && user.access_token.present?
    user[:mine_fb_data] = user.access_token_changed? && !user[:recreate]
  end

  # Alert notification manager to mine contacts based on the 
  # flag set in before_update
  #
  def after_update(user)

    if user[:recreate]
      ProcessingQueue.push(
        UserDelayedObserver,
        :after_create,
        user.id) 
    end

    if user[:mine_fb_data]
      ProcessingQueue.push(
        UserDelayedObserver,
        :after_update,
        user.id,
        {:mine => true}) 

      user[:mine_fb_data] = false
    end
  end

end
