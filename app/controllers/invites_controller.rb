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
        :image => "http://placehold.it/160x120",
        :caption => "Boho"},
      {
        :id => 2,
        :image => "http://placehold.it/160x120",
        :caption => "Chic"},
      {
        :id => 3,
        :image => "http://placehold.it/160x120",
        :caption => "Chic"},
      {
        :id => 4,
        :image => "http://placehold.it/160x120",
        :caption => "Chic"},
      {
        :id => 5,
        :image => "http://placehold.it/160x120",
        :caption => "Chic"},
      {
        :id => 6,
        :image => "http://placehold.it/160x120",
        :caption => "Chic"}]
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
