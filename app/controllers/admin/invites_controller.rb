class Admin::InvitesController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  #
  #
  def index

    case params[:filter].to_sym
    when :recent
      @invites = Invite.with_user.by_id.limit(300)

      @converts = {}

      User.find_all_by_fb_user_id(@invites.map(&:recipient_id)).each do |user|
        @converts[user.fb_user_id] = user
      end

      User.find_all_by_email(@invites.map(&:recipient_id)).each do |user|
        @converts[user.email] = user
      end

      @view = "recent"
    end

    render @view
  end
end
