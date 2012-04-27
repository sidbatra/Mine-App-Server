class InvitesController < ApplicationController
  before_filter :login_required

  # Display page for creating invites.
  #
  def new
  end

  # Create an invite.
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
