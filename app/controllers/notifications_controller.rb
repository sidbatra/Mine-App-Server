class NotificationsController < ApplicationController
  before_filter :login_required

  def index

    @notifications = Notification.
                      for(self.current_user.id).
                      limit([self.current_user.unread_notifications_count,10].max).
                      with_resource.
                      by_updated_at.
                      all

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  def update
    @notifications = Notification.find_all_by_id params[:unread_ids].split(",")
    @notifications.map(&:read)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
