# Handle requests for user invites
#
class InvitesController < ApplicationController
  before_filter :login_required

  # Create an invite 
  #
  def create
    @invite = Invite.add(self.current_user.id,params[:fb_user_id])
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
