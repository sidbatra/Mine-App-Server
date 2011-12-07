# Handle requests for the comments resource
#
class CommentsController < ApplicationController
  before_filter :login_required,  :only => [:create]

  # Create a new comment
  #
  def create
    @comment = Comment.add(params,self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Fetch comments on a commentable entity
  #
  def index
    @comments = Comment.on(
                  params[:source_type],
                  params[:source_id]).with_user
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
