class SearchController < ApplicationController

  # Fetch a set of search results
  #
  def index
    @images   = []
    @query    = params[:q]
    @page     = params[:page] ? params[:page].to_i : 0
    per_page  = params[:per_page] ? params[:per_page].to_i : 10
    hydra     = Typhoeus::Hydra.new


    medium_url  = WebSearch.on_images(@query,:medium,per_page,@page,true)
    request     = Typhoeus::Request.new(medium_url)

    request.on_complete do |response| 
      web_search = JSON.parse(response.body)["SearchResponse"] rescue nil
      next unless web_search

      @images += web_search["Image"]["Results"].map do |image|
        {
          :thumb => image["Thumbnail"]["Url"],
          :image => image["MediaUrl"],
          :source => image["Url"],
          :title => image["Title"]
          }
      end #if false
    end

    hydra.queue request



    large_url  = WebSearch.on_images(@query,:large,per_page,@page,true)
    request     = Typhoeus::Request.new(large_url)

    request.on_complete do |response| 
      web_search = JSON.parse(response.body)["SearchResponse"] rescue nil
      next unless web_search

      @images += web_search["Image"]["Results"].map do |image|
        {
          :thumb => image["Thumbnail"]["Url"],
          :image => image["MediaUrl"],
          :source => image["Url"],
          :title => image["Title"]
          }
      end #if false
    end

    hydra.queue request


    amazon_url = AmazonProductSearch.fetch_products(@query,@page+1,true)
    logger.info amazon_url
    request = Typhoeus::Request.new(amazon_url)
    request.on_complete do |response| 
      @images += Amazon::Ecs::Response.new(response.body).items.map do |image|
                  thumb = image.get('MediumImage/URL')
                  large = image.get('LargeImage/URL')
                  next unless thumb and large
                  {
                    :thumb => thumb,
                    :image => large,
                    :source => image.get('DetailPageURL'),
                    :title => image.get('ItemAttributes/Title')
                  }
                end.compact
    end #if false

    hydra.queue request

    hydra.run

    #@products = Product.fulltext_search(@query,@page+1,per_page)

  #rescue => ex
  #  handle_exception(ex)
  #ensure
    respond_to do |format|
      format.json 
    end
  end

end
