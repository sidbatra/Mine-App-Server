class LikesController < ApplicationController
  before_filter :login_required, :except => :index

  # List of native likes 
  # 
  # params[:purchase_ids] - Comma separated list for all purchase 
  #                        ids whose likes need to be fetched
  #
  def index
    purchase_ids  = params[:purchase_ids].split(",")
    @likes        = Like.with_user.find_all_by_purchase_id(purchase_ids)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Create a new like 
  #
  def create
    purchase_id = params[:purchase_id]
    like        = Like.add(purchase_id,self.current_user.id)

    @like = {:purchase_id => purchase_id,
             :fb_user_id  => self.current_user.fb_user_id,
             :name        => self.current_user.full_name,
             :id          => like.id} 
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
