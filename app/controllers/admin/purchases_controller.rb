class Admin::PurchasesController < ApplicationController
  layout nil
  before_filter :admin_required

  #
  #
  def index

    case params[:filter].to_sym
    when :recent
      @purchases = Purchase.with_user.by_id.limit(300)
      @view = "recent"
    end

    render @view
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
