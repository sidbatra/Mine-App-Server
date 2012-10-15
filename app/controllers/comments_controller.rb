class CommentsController < ApplicationController
  before_filter :login_required

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

  def index
    purchase = Purchase.find params[:purchase_id]

    @key = ["v1",purchase,"comments"]
    @cache_options = {}
    @comments = Comment.
                  select(:id,:user_id,:message).
                  with_user.
                  for(purchase.id)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
