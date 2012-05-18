class ProductsController < ApplicationController

  # Fetch a set of products based on the given query.
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

      if @sane_query.match(/http/)
        @title,@products = product_url_search(@sane_query)
      else
        @key,@sane_query,@products = product_text_search(
                                      @sane_query,
                                      @page,
                                      @per_page)
      end

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

      hydra.queue search_web_images(sane_query,:medium,page,per_page)
      hydra.queue search_web_images(sane_query,:large,page,per_page)
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

    response = Typhoeus::Request.get(spellcheck_url,
                :username => "",
                :password => CONFIG[:windows_azure_key]).body
    response = JSON.parse(response)["d"]["results"]
    text = response[0]["Value"] if response.present?
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
                             "",
                             product.title)
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
                                product.get('ASIN'),
                                product.get('ItemAttributes/Title'))

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
  # size - Symbol. Size bucket of the results. :medium or :large
  # page - Integer. Page number of results to be fetched.
  # per_page - Integer. Total results per page.
  #
  # returns - Typhoeus::Request. Typhoeus request object. Plus results are 
  #           added to the @results  instance variable after they're 
  #           asynchronously fetched.
  #
  def search_web_images(query,size,page,per_page)
    url = WebSearch.on_images(query,size,per_page,page*per_page,true)
    request = Typhoeus::Request.new(url,
                :username => "",
                :password => CONFIG[:windows_azure_key])

    request.on_complete do |response| 
      begin
        web_search = JSON.parse(response.body)["d"]
        key = "web_" + size.to_s

        @results[key.to_sym] = web_search["results"].map do |product|
                                begin
                                  product_search_hash(
                                    product["Thumbnail"]["MediaUrl"],
                                    product["MediaUrl"],
                                    product["SourceUrl"],
                                    "",
                                    "")
                                rescue => ex
                                  LoggedException.add(__FILE__,__method__,ex)
                                end
                              end #if web_search["__next"]
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

  # Search for potential products within a webpage.
  #
  # query - String. Valid url within which products are searched.
  #
  # returns - Array. [title,products].
  #             title - String. Title of the webpage.
  #             products - Array. Array of product search hash objects.
  #
  def product_url_search(query)
    products = []
    title = ""

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    agent.get(query)

    if agent.page.is_a? Mechanize::Page
      base_uri = URI.parse(URI.encode(query))
      
      images = agent.page.images.map do |img| 
                begin
                  img.src.match(/^http/) ? 
                    img.src : 
                    URI.decode(base_uri.merge(URI.encode(img.src)).to_s).
                         gsub("¥","\\")
                rescue
                  img.src ? img.src : ''
                end
               end

      title = agent.page.title
    else
      images = [query]
    end

    products = images.map do |image|
                product_search_hash(image,"","","","")
               end
  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  ensure
    return [title,products]
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
    "product_search_%s_%d" % [Base64.encode64(query).gsub("\n","")[0..99],page]
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
        unique_id,
        title)
    { :medium_url => medium_image_url,
      :large_url  => large_image_url,
      :source_url => source_url,
      :uniq_id    => unique_id,
      :title => title}
  end

end


