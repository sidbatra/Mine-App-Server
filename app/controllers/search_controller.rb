class SearchController < ApplicationController

  # Fetch a set of search results
  #
  def index
    @products   = []
    @query      = params[:q]
    @sane_query = @query
    @page       = params[:page] ? params[:page].to_i : 0
    @key        = generate_cache_key(@sane_query,@page)
    per_page    = 10

    unless fragment_exist? @key

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


      @key = generate_cache_key(@sane_query,@page)

      unless fragment_exist? @key
    

        medium_url  = WebSearch.on_images(@sane_query,:medium,
                                  per_page,@page*per_page,true)
        request     = Typhoeus::Request.new(medium_url)

        request.on_complete do |response| 
          begin
            web_search = JSON.parse(response.body)["SearchResponse"] 
            total = web_search["Image"]["Total"]
            offset = web_search["Image"]["Offset"]

            web_medium_products = web_search["Image"]["Results"].map do |product|
                                    begin
                                      product_search_hash(
                                        product["Thumbnail"]["Url"],
                                        product["MediaUrl"],
                                        product["Url"],
                                        "")
                                    rescue => ex
                                      LoggedException.add(__FILE__,__method__,ex)
                                    end
                                  end if total - offset > per_page
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)
          end
        end

        hydra.queue request



        large_url  = WebSearch.on_images(@sane_query,:large,
                                per_page,@page*per_page,true)
        request     = Typhoeus::Request.new(large_url)

        request.on_complete do |response| 
          begin
            web_search = JSON.parse(response.body)["SearchResponse"] 
            total = web_search["Image"]["Total"]
            offset = web_search["Image"]["Offset"]

            web_large_products = web_search["Image"]["Results"].map do |product|
                                  begin
                                    product_search_hash(
                                      product["Thumbnail"]["Url"],
                                      product["MediaUrl"],
                                      product["Url"],
                                      "")
                                  rescue => ex
                                    LoggedException.add(__FILE__,__method__,ex)
                                  end
                                end if total - offset > per_page
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
                               product.id.to_s)
                           end

        @products = inhouse_products + amazon_products + 
                      web_medium_products + web_large_products

      end # fragment exists

    end #fragment exists

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end


  protected

  # Generates a cache key for the results of a query at a page.
  #
  # query - String. The query string whose results are to be cached.
  # page - Integer. The page number of results to be cached.
  #
  # returns - String. Cache key formed by sanitizing the query and combining it
  #             with the page number
  #
  def generate_cache_key(query,page)
    KEYS[:product_search] % [Base64.encode64(query).chomp,page]
  end

  # Create hash representing a result in a product search.
  #
  # medium_image_url - String. Url for a medium sized product image.
  # large_image_url - String. Url for a large sized product image.
  # source_url - String. Url where detailed product information is found
  # unique_id - String. Identifier to uniquely identify the product. 
  #                     Pass in empty string if inapplicable
  #
  def product_search_hash(
        medium_image_url,
        large_image_url,
        source_url,
        unique_id)
    {
      :medium_url => medium_image_url,
      :large_url  => large_image_url,
      :source_url => source_url,
      :uniq_id    => unique_id}
  end

end

