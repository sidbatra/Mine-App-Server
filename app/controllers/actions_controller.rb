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

  # Fetch actions on an actionable entity
  #
  def index
    @actions = Action.select(:id,:name,:user_id).on(
                params[:source_type],
                params[:source_id]).with_user.by_id
    @key     = KEYS[:action_actionable] % 
                [params[:source_id],params[:source_type].capitalize]
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
