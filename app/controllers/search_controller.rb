class SearchController < ApplicationController

  # Fetch a set of search results
  #
  def index
    @products   = []
    @query      = params[:q]
    @sane_query = @query
    @page       = params[:page] ? params[:page].to_i : 0
    @key        = generate_cache_key(@sane_query,@page)
    @title      = ""
    @per_page   = 10

    unless fragment_exist? @key
      @key,@sane_query,@products = product_text_search(
                                    @sane_query,
                                    @page,
                                    @per_page)
    end 

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end


  protected

  # Search different services for products matching query
  # and display a particular page of results
  #
  # query - String. Bunch of keywords to search products by.
  # page - Integer. Page number of results to be returned.
  # per_page - Integer. Total number of results per page.
  #
  # returns - Array. [key,sane_query,products].
  #           key - String. Cache key to be used in the view.
  #           sane_query - String. Sanitized spell checked query string.
  #           products - Array. Array of product search hash objects.
  #
  def product_text_search(query,page,per_page)
    hydra  = Typhoeus::Hydra.new
    products = []
    @results = {:web_medium => [],
                :web_large  => [],
                :amazon     => [],
                :inhouse    => []}

    sane_query = check_spelling(query)
    key = generate_cache_key(sane_query,page)

    unless fragment_exist? key

      hydra.queue search_medium_web_images(sane_query,page,per_page)
      hydra.queue search_large_web_images(sane_query,page,per_page)
      hydra.queue search_amazon_products(sane_query,page,per_page)
      hydra.run

      search_inhouse_products(sane_query,page,per_page)

      products = @results[:inhouse] + 
                  @results[:amazon] + 
                  @results[:web_medium] + 
                  @results[:web_large]
    end

    [key,sane_query,products]
  end

  # Spell check text using a web based spell check service.
  #
  # text - String. The text to be spell checked.
  #
  # returns - String. The spell checked & corrected version of the text
  #
  def check_spelling(text)
    spellcheck_url = WebSearch.for_spelling(text,true)
    response = JSON.parse(Typhoeus::Request.get(spellcheck_url).body)
    response = response["SearchResponse"]["Spell"]
    text = response["Results"][0]["Value"] if response
  rescue => ex
      LoggedException.add(__FILE__,__method__,ex)
  ensure
    return text
  end

  # Search inhouse products for a query and pagination.
  #
  # query - String. Keywords to find a matching product.
  # page - Integer. Page of results to be fetched.
  # per_page - Integer. Total results on every page.
  #
  # returns - Array. Array of product search hash objects. Plus results
  #           are added to the @results instance variable.
  #
  def search_inhouse_products(query,page,per_page)
    @results[:inhouse] = Product.fulltext_search(
                            query,
                            page+1,
                            per_page).map do |product|

                           product_search_hash(
                             product.thumbnail_url,
                             product.image_url,
                             product.source_url,
                             product.id.to_s)
                         end
  end

  # Search amazon products for a query and pagination.
  #
  # query - String. Keywords to find a matching product.
  # page - Integer. Page of results to be fetched.
  # per_page - Integer. Total results on every page.
  #
  # returns - Typhoeus request object. Plus results are added to the @results
  #           instance variable after they're asynchronously fetched.
  #
  def search_amazon_products(query,page,per_page)
    amazon_url = AmazonProductSearch.fetch_products(query,page+1,true)
    request = Typhoeus::Request.new(amazon_url)

    request.on_complete do |response| 
      begin
        @results[:amazon] = Amazon::Ecs::Response.new(
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

    request
  end

  # Search the web for medium images matching a query and pagination.
  #
  # query - String. Keywords to find images by.
  # page - Integer. Page number of results to be fetched.
  # per_page - Integer. Total results per page.
  #
  # returns - Typhoeus::Request. Typhoeus request object. Plus results are 
  #           added to the @results  instance variable after they're 
  #           asynchronously fetched.
  #
  def search_medium_web_images(query,page,per_page)
    medium_url = WebSearch.on_images(query,:medium,per_page,page*per_page,true)
    request = Typhoeus::Request.new(medium_url)

    request.on_complete do |response| 
      begin
        web_search = JSON.parse(response.body)["SearchResponse"] 
        total = web_search["Image"]["Total"]
        offset = web_search["Image"]["Offset"]

        @results[:web_medium] = web_search["Image"]["Results"].map do |product|
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

    request
  end

  # Search the web for large images matching a query and pagination.
  #
  # query - String. Keywords to find images by.
  # page - Integer. Page number of results to be fetched.
  # per_page - Integer. Total results per page.
  #
  # returns - Typhoeus::Request. Typhoeus request object. Plus results are 
  #           added to the @results  instance variable after they're 
  #           asynchronously fetched.
  #
  def search_large_web_images(query,page,per_page)
    large_url = WebSearch.on_images(query,:large,per_page,page*per_page,true)
    request = Typhoeus::Request.new(large_url)

    request.on_complete do |response| 
      begin
        web_search = JSON.parse(response.body)["SearchResponse"] 
        total = web_search["Image"]["Total"]
        offset = web_search["Image"]["Offset"]

        @results[:web_large] = web_search["Image"]["Results"].map do |product|
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

    request
  end

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

