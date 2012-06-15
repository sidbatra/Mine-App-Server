class Admin::PurchasesController < ApplicationController
  before_filter :admin_required

  def index
    @filter = params[:filter].to_sym

    case @filter
    when :recent
      @purchases = Purchase.with_user.by_id.limit(300)
    end

    render :partial => @filter.to_s,
           :layout => "application"
  end

end
