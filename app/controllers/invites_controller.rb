class InvitesController < ApplicationController
  before_filter :login_required

  # Display page for creating invites.
  #
  def new
  end

  # Create single or multiple invites
  #
  def create
    @invite = nil 
    invites = params[:invites]

    if invites
      invites.each do |index,invite|
        invite[:message] = params[:message] 
        Invite.add(invite,self.current_user.id)
      end
    else
      Invite.add(params,self.current_user.id)
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
