# Handle requests for the invites resource
#
class InvitesController < ApplicationController
  before_filter :login_required

  # Display UI for creating invites
  #
  def new
    @styles = CONFIG[:styles]
  end

  # Create one or more invites 
  #
  def create
    params[:user_id] = self.current_user.id

    @invite = Invite.add(params)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
