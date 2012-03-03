# Handle requests for the invites resource
#
class InvitesController < ApplicationController
  before_filter :login_required

  # Display UI for creating invites
  #
  def new
    @styles = [
      {
        :id => 1,
        :image => "invite/glam2.jpg",
        :caption => "Glam"},
      {
        :id => 2,
        :image => "invite/casual3.jpg",
        :caption => "Casual"},
      {
        :id => 3,
        :image => "invite/athletic2.jpg",
        :caption => "Athletic"},
      {
        :id => 4,
        :image => "invite/preppy.jpg",
        :caption => "Preppy"},
      {
        :id => 5,
        :image => "invite/hipster.jpg",
        :caption => "Hipster"},
      {
        :id => 6,
        :image => "invite/smart2.jpg",
        :caption => "Smart"}]
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
