class UserObserver < ActiveRecord::Observer

  # Build settings for a user who's about to be created.
  #
  def before_create(user)
    user.visited_at = Time.now
    user.build_setting  
  end

  # Hand off to the delayed observer.
  #
  def after_create(user)
    ProcessingQueue.push(
      UserDelayedObserver,
      :after_create,
      user.id) if user.is_registered?
  end

  # Test the user object for the following events:
  #   mine_fb_data - Mine facebook data.
  #
  def before_update(user)
    user[:mine_fb_data] = user.access_token_changed? && 
                          user.access_token.present?
  end

  # Hand over to the delayed observer after refering to the events setup in
  # the before_update method.
  #
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
        {:mine_fb_data => true}) 

      user[:mine_fb_data] = false
    end
  end

end
