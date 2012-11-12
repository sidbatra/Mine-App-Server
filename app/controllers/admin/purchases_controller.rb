class Admin::PurchasesController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  #
  #
  def index

    case params[:filter].to_sym
    when :recent
      @purchases = Purchase.approved.with_user.by_id.limit(500)
      @view = "recent"
    when :special
      @purchases = Purchase.with_user.by_id.special
      @view = "special"
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

  #
  #
  def update
    purchase = Purchase.find(params[:id])
    purchase.update_attributes(params[:purchase])
    redirect_to admin_full_purchase_path(purchase.user.handle,purchase.handle)
  end

end
