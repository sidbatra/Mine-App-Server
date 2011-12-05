# Handle requests for the invites resource
#
class InvitesController < ApplicationController
  before_filter :login_required

  # Display UI for creating one or multiple invites
  #
  def new
  end

  # Create one or more invites 
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
