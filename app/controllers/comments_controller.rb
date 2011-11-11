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

  # Fetch comments on a particular product
  #
  def index
    @comments = Comment.on_product(params[:product_id]).with_user
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
