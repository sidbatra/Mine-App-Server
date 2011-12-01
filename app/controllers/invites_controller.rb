# Handle requests for user invites
#
class InvitesController < ApplicationController
  before_filter :login_required

  # Create an invite 
  #
  def create
    @invite = nil

    params[:fb_user_ids].each do |fb_user_id|
      Invite.add(self.current_user.id,fb_user_id)
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
