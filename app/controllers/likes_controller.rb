class LikesController < ApplicationController
  before_filter :login_required, :except => :index

  # Create a new like 
  #
  def create
    @like = Like.add(params[:purchase_id],self.current_user.id)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
