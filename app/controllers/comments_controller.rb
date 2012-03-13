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
    @comments = Comment.select(:id,:user_id,:data,:created_at).
                  on(params[:source_type],params[:source_id]).
                  with_user
    @key      = KEYS[:comment_commentable] % 
                  [params[:source_id],params[:source_type].capitalize]
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
