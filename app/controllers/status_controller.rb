class StatusController < ApplicationController
  before_filter :login_required

  # Display a status for the given client.
  #
  def show
    self.current_user.fb_access_token_valid?
    self.current_user.visited

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
