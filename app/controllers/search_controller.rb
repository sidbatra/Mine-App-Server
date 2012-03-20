class SearchController < ApplicationController

  # Fetch a set of search results
  #
  def index
    @products   = []
    @query      = params[:q]
    @sane_query = @query
    @page       = params[:page] ? params[:page].to_i : 0
    per_page    = params[:per_page] ? params[:per_page].to_i : 10

    hydra               = Typhoeus::Hydra.new
    web_medium_products = []
    web_large_products  = []
    amazon_products     = []
    inhouse_products    = []

    begin
      spellcheck_url = WebSearch.for_spelling(@query,true)
      response = JSON.parse(Typhoeus::Request.get(spellcheck_url).body)
      response = response["SearchResponse"]["Spell"]
      @sane_query = response["Results"][0]["Value"] if response
    rescue => ex
      LoggedException.add(__FILE__,__method__,ex)
    end


    medium_url  = WebSearch.on_images(@sane_query,:medium,per_page,@page,true)
    request     = Typhoeus::Request.new(medium_url)

    request.on_complete do |response| 
      begin
        web_search = JSON.parse(response.body)["SearchResponse"] 

        web_medium_products = web_search["Image"]["Results"].map do |product|
                                begin
                                  product_search_hash(
                                    product["Thumbnail"]["Url"],
                                    product["MediaUrl"],
                                    product["Url"],
                                    product["Title"],
                                    "")
                                rescue => ex
                                  LoggedException.add(__FILE__,__method__,ex)
                                end
                              end 
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    hydra.queue request



    large_url  = WebSearch.on_images(@sane_query,:large,per_page,@page,true)
    request     = Typhoeus::Request.new(large_url)

    request.on_complete do |response| 
      begin
        web_search = JSON.parse(response.body)["SearchResponse"] 

        web_large_products = web_search["Image"]["Results"].map do |product|
                              begin
                                product_search_hash(
                                  product["Thumbnail"]["Url"],
                                  product["MediaUrl"],
                                  product["Url"],
                                  product["Title"],
                                  "")
                              rescue => ex
                                LoggedException.add(__FILE__,__method__,ex)
                              end
                            end
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    hydra.queue request


    amazon_url = AmazonProductSearch.fetch_products(@sane_query,@page+1,true)
    request = Typhoeus::Request.new(amazon_url)

    request.on_complete do |response| 
      begin
        amazon_products = Amazon::Ecs::Response.new(
                            response.body).items.map do |product|
                            begin
                              medium_url = product.get('MediumImage/URL')
                              large_url = product.get('LargeImage/URL')

                              next unless medium_url and large_url
                              
                              product_search_hash(
                                medium_url,
                                large_url,
                                product.get('DetailPageURL'),
                                product.get('ItemAttributes/Title'),
                                product.get('ASIN'))

                            rescue => ex
                              LoggedException.add(__FILE__,__method__,ex)
                            end
                          end.compact
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end 

    hydra.queue request


    hydra.run


    inhouse_products = Product.fulltext_search(
                          @sane_query,
                          @page+1,
                          per_page).map do |product|

                         product_search_hash(
                           product.thumbnail_url,
                           product.image_url,
                           product.source_url,
                           product.title,
                           product.id.to_s)
                       end

    @products = inhouse_products + amazon_products + 
                  web_medium_products + web_large_products

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end


  protected

  # Create hash representing a result in a product search.
  #
  # medium_image_url - String. Url for a medium sized product image.
  # large_image_url - String. Url for a large sized product image.
  # source_url - String. Url where detailed product information is found
  # title - String. Title of the product.
  # unique_id - String. Identifier to uniquely identify the product. 
  #                     Pass in empty string if inapplicable
  #
  def product_search_hash(
        medium_image_url,
        large_image_url,
        source_url,
        title,
        unique_id)
    {
      :medium_url => medium_image_url,
      :large_url  => large_image_url,
      :source_url => source_url,
      :title      => title,
      :uniq_id    => unique_id}
  end

end

