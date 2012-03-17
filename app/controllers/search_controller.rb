class SearchController < ApplicationController

  # Fetch a set of search results
  #
  def index
    @query = params[:q]

    logger.info @query

    if @query
      @products = Product.limit(10).
                    all(:conditions => ['title like ?',"%#{@query}%"])
      @medium_images = WebSearch.on_images(@query,:medium)
      @large_images = WebSearch.on_images(@query,:large)
      @amazon_products = AmazonProductSearch.fetch_products(@query)
    end
  end

end
