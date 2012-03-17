class SearchController < ApplicationController

  # Fetch a set of search results
  #
  def index
    @query = params[:q]

    if @query
      hydra = Typhoeus::Hydra.new

      medium_url = WebSearch.on_images(@query,:medium,10,0,true)
      request = Typhoeus::Request.new(medium_url)
      request.on_complete{|r| @medium_images = WebSearch.new(r.body)}
      hydra.queue request

      large_url = WebSearch.on_images(@query,:large,10,0,true)
      request = Typhoeus::Request.new(large_url)
      request.on_complete{|r| @large_images = WebSearch.new(r.body)}
      hydra.queue request

      hydra.run

      #@medium_images = WebSearch.on_images(@query,:medium)
      #@large_images = WebSearch.on_images(@query,:large)

      @amazon_products = AmazonProductSearch.fetch_products(@query)

      @products = Product.limit(10).
                    all(:conditions => ['title like ?',"%#{@query}%"])
    end
  end

end
