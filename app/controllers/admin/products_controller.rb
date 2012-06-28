class Admin::ProductsController < ApplicationController
  before_filter :admin_required 

  # Fetch products based on different filters
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :store
      @query = params[:q]
      @store = Store.find(params[:store_id])
      @page = params[:page] ? params[:page].to_i : 0

      @count = 100

      if @query
        @products,@total = Product.fulltext_search(@query,
                              @store.id,
                              @page+1,
                              @count)
      else
        @total = Product.for_store(@store.id).count
        @products = Product.for_store(@store.id).
                      limit(@count).
                      offset(@count * @page)
      end

    end

    render @filter.to_s
  end
end
