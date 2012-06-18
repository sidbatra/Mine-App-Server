class Admin::PurchasesController < ApplicationController
  before_filter :admin_required

  #
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :recent
      @purchases = Purchase.with_user.by_id.limit(300)
    end

    render :partial => @filter.to_s,
           :layout => "application"
  end

  #
  #
  def show
    if params[:id]
      @purchase = Purchase.find(params[:id])
    else
      user = User.find_by_handle(params[:user_handle])

      @purchase = Purchase.find_by_user_id_and_handle(
                   user.id,
                   params[:purchase_handle])
    end
  end

end
