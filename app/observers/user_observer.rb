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
      user.id) 
  end

  # Test the user object for the following events:
  #   mine_fb_data - Mine facebook data.
  #
  def before_update(user)
    user[:mine_fb_data] = user.access_token_changed? && 
                          user.access_token.present?
    user[:mine_tw_data] = user.tw_access_token_changed? && 
                          user.tw_access_token.present?
    user[:dispatch_welcome_email] = !user.email_was.present? &&
                                      user.email.present?
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

    if user[:mine_fb_data] || 
        user[:mine_tw_data] || 
        user[:dispatch_welcome_email]

      ProcessingQueue.push(
        UserDelayedObserver,
        :after_update,
        user.id, {
          :mine_fb_data => user[:mine_fb_data],
          :mine_tw_data => user[:mine_tw_data],
          :dispatch_welcome_email => user[:dispatch_welcome_email]}) 

      user[:mine_fb_data] = false
      user[:mine_tw_data] = false
      user[:dispatch_welcome_email] = false
    end
  end

end
