# Handle requests for the actions resource
#
class ActionsController < ApplicationController
  before_filter :login_required,  :only => [:create]

  # Create a new action
  #
  def create
    @action = Action.add(params,self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Fetch actions on a particular product
  #
  def index
    @actions = Action.on_product(params[:product_id]).with_user
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
