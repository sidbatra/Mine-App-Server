class CommentsController < ApplicationController
  before_filter :login_required

  # List of native comments 
  # 
  # params[:purchase_ids] - Comma separated list for all purchase 
  #                        ids whose comments need to be fetched
  #
  def index
    purchase_ids  = params[:purchase_ids].split(",")
    @comments     = Comment.with_user.for(purchase_ids)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Create a new comment
  #
  def create
    comment   = Comment.add(params,self.current_user.id) 

    @comment  = {:purchase_id  => comment.purchase_id,
                 :id           => comment.id,
                 :messsage     => comment.message,
                 :from         => {:name => self.current_user.full_name,
                                   :id   => self.current_user.fb_user_id}}
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
