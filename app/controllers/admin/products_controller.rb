class Admin::ProductsController < ApplicationController
  before_filter :admin_required 

  # Fetch products based on different filters
  #
  def index
    @filter = params[:filter].to_sym
    @layout = "application"

    case @filter
    when :store
      @store_id = params[:store_id]
      @count = 500
      @total = Product.for_store(@store_id).count
      @page = params[:page] ? params[:page].to_i : 0
      @products = Product.for_store(@store_id).
                    limit(@count).
                    offset(@count * @page)
      @stores = Store.unapproved.sorted

    end

    render @filter.to_s
  end
end
