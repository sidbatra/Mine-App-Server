class NotificationObserver < ActiveRecord::Observer

  def after_create(notification)
    increment_user_unread_count notification
  end

  def before_update(notification)
    if notification.unread_changed?
      if notification.unread_was
        decrement_user_unread_count notification
      else
        increment_user_unread_count notification
      end
    end
  end

  def after_destroy(notification)
    if notification.unread
      decrement_user_unread_count notification
    end
  end


  protected

  def increment_user_unread_count(notification)
    User.increment_unread_notifications_count notification.user_id
  end

  def decrement_user_unread_count(notification)
    User.decrement_unread_notifications_count notification.user_id
  end
end

