# Handle requests for the comments resource
#
class CommentsController < ApplicationController
  before_filter :login_required,  :only => [:create]

  # Create a new comment
  #
  def create
    @comment = Comment.add(
                        params[:comment],
                        self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
  end
end
