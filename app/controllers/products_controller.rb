class ProductsController < ApplicationController

  # Fetch a set of products based on the given query.
  #
  def index
    @products   = []
    @query      = params[:q]
    @sane_query = @query.strip
    @page       = params[:page] ? params[:page].to_i : 0
    @key        = generate_cache_key(@sane_query,@page)
    @title      = ""
    @per_page   = 10
    @mobile     = params[:mobile]

    unless fragment_exist? @key

      if @sane_query.match(/http/)
        @title,@products = product_url_search(@sane_query) if @page.zero?
      else
        @key,@sane_query,@products = product_text_search(
                                      @sane_query,
                                      @page,
                                      @per_page)
      end

    end 

    Search.add(
      {:query => @query,:source => SearchSource::New},
      self.current_user.id) if @page.zero?

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
                :inhouse    => [],
                :google     => [],
                :itunes     => []}

    sane_query = check_spelling(query,page)
    key = generate_cache_key(sane_query,page)

    unless fragment_exist? key

      hydra.queue search_google_shopping(sane_query,page,per_page)
      hydra.queue search_web_images(sane_query,:medium,page,per_page)
      hydra.queue search_web_images(sane_query,:large,page,per_page)
      hydra.queue search_amazon_products(sane_query,page,per_page)
      hydra.queue search_itunes_apps(sane_query,5) if page.zero?
      hydra.run

      search_inhouse_products(sane_query,page,per_page)

      if is_searching_for_apps(sane_query)
        products += @results[:itunes]
      else
        clean_query = sanitize_itunes_query sane_query.downcase

        @results[:itunes].each do |app|
          title = app[:title].downcase
          #logger.info title
          products << app if title =~ Regexp.new("^#{clean_query}")
        end
      end

      products += @results[:google] + 
                  @results[:inhouse] + 
                  @results[:amazon] 

      products += @results[:web_large] + 
                  @results[:web_medium] if products.length < 10 || page > 1
    end

    [key,sane_query,products]
  end

  # Spell check text using a web based spell check service.
  #
  # text - String. The text to be spell checked.
  #
  # returns - String. The spell checked & corrected version of the text
  #
  def check_spelling(text,page)
    corrected_texts_hash = (session[:corrected_texts] ||= Hash.new(false))

    if corrected_texts_hash[text] == true
      return text 
    end

    if page.zero? && corrected_texts_hash.include?(text)
      corrected_texts_hash[text] = true
      return text
    end


    spellcheck_url = WebSearch.for_spelling(text,true)

    response = Typhoeus::Request.get(spellcheck_url,
                :connect_timeout => 1000,
                :timeout => 1500,
                :username => "",
                :password => CONFIG[:windows_azure_key]).body

    if response.present?
      response = JSON.parse(response)["d"]["results"]

      corrected_text = nil
      corrected_text = response[0]["Value"] if response.present?

      if corrected_text.present? 
        corrected_texts_hash[text] = false
        text = corrected_text 
      end
    end

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
                            nil,
                            page+1,
                            per_page).first.map do |product|

                           #TODO: Optimize for @mobile
                           product_search_hash(
                             product.thumbnail_url,
                             product.image_url,
                             product.source_url,
                             "MI-#{product.id}",
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
    request = Typhoeus::Request.new(amazon_url,
                :connect_timeout => 1000,
                :timeout => 3500)

    request.on_complete do |response| 
      begin
        @results[:amazon] = Amazon::Ecs::Response.new(response.body).items.map do |item|
                            begin
                              product = AmazonProduct.new(item)
                              medium_url = @mobile ? 
                                            product.small_image_url :
                                            product.medium_image_url
                              large_url = product.large_image_url

                              next unless medium_url and large_url
                              
                              product_search_hash(
                                medium_url,
                                large_url,
                                product.page_url,
                                product.custom_product_id,
                                product.title)

                            rescue => ex
                              LoggedException.add(__FILE__,__method__,ex)
                              nil
                            end
                          end.compact
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end 

    request
  end

  # Search via google shopping api.
  #
  # query - The String query to search the api.
  # page - The Integer page number of results to display.
  # per_page - The Integer total results on the page.
  #
  # returns - Typhoeus::Request. Typhoeus request object. Plus results are 
  #           added to the @results  instance variable after they're 
  #           asynchronously fetched.
  #
  def search_google_shopping(query,page,per_page)
    url = GoogleShopping.search_products(
                          query,
                          @mobile ? 75 : 180,
                          per_page,
                          page+1,
                          true)

    request = Typhoeus::Request.new(url,
                :connect_timeout => 1000,
                :timeout => 3000)

    request.on_complete do |response| 
      begin
        google_shopping = JSON.parse(response.body) if response.body.present?
        key = "google"

        @results[key.to_sym] = google_shopping["items"].map do |item|
                                begin
                                  product = item["product"]

                                  next unless product && product["images"]

                                  product_search_hash(
                                    product["images"][0]["thumbnails"][0]["link"],
                                    product["images"][0]["link"],
                                    product["link"],
                                    "GO-#{product["googleId"]}",
                                    product["title"])
                                rescue => ex
                                  LoggedException.add(__FILE__,__method__,ex)
                                  nil
                                end
                              end.compact if google_shopping && google_shopping["items"]
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

  # Search apps via the itunes interface.
  #
  # query - The String query to search the api.
  # per_page - The Integer total results on the page.
  #
  # returns - Typhoeus::Request. Typhoeus request object. Plus results are 
  #           added to the @results  instance variable after they're 
  #           asynchronously fetched.
  #
  def search_itunes_apps(query,per_page)
    clean_query = sanitize_itunes_query query
    url = Itunes.search_apps(clean_query,per_page,true)

    request = Typhoeus::Request.new(url,
                :connect_timeout => 1000,
                :timeout => 3000)

    request.on_complete do |response| 
      begin
        apps = JSON.parse(response.body)
        key = "itunes"

        @results[key.to_sym] = apps["results"].map do |result|
                                begin
                                  next unless result 

                                  product = ItunesProduct.new result

                                  product_search_hash(
                                    product.large_image_url,
                                    product.large_image_url,
                                    product.page_url,
                                    product.custom_product_id,
                                    product.title)
                                rescue => ex
                                  LoggedException.add(__FILE__,__method__,ex)
                                  nil
                                end
                              end.compact #if apps["results"]
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
                :connect_timeout => 1000,
                :timeout => 2500,
                :username => "",
                :password => CONFIG[:windows_azure_key])

    request.on_complete do |response| 
      begin
        next unless response.body.present?

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
                                  nil
                                end
                              end.compact if web_search["__next"] || page.zero?
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
    agent.open_timeout = 6
    agent.read_timeout = 6
    agent.user_agent_alias = 'Mac Safari'
    agent.get(URI.encode(query))

    if agent.page.is_a? Mechanize::Page
      base_uri = URI.parse(URI.encode(query))
      
      images = []

      #begin
      #  og_image = agent.page.parser.at('meta[property="og:image"]')
      #  images << og_image['content'] if og_image
      #rescue
      #  LoggedException.add(__FILE__,__method__,ex)
      #end
        
      images += agent.page.images.map do |img| 
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
                product_search_hash(image,image,query,"","")
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

  def sanitize_itunes_query(query)
    query.gsub(/(app|iphone|ipad|ipod|ios|for)(\s|\z)/i,"")
  end

  def is_searching_for_apps(query)
    query.match(/app(\s|\z)/i) || query.match(/for (iphone|ipad|ios|ipod)/i)
  end

end


