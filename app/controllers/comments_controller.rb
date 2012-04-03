class CommentsController < ApplicationController
  before_filter :login_required

  # List of facebook comments for products pushed to gallery or timeline
  # 
  # params[:product_ids] - Comma separated list for all product 
  #                        ids whose comments need to be fetched
  #
  def index
    @comments   = {}
    product_ids = params[:product_ids].split(",")
    products    = Product.find_all_by_id(product_ids, :include => :user)
   
    hydra = Typhoeus::Hydra.new

    products.each do |product|
      hydra.queue fetch_facebook_comments(product) if product.fb_object_id 
    end

    hydra.run
    
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end


  protected

  # Fetch facebook comments for a particular product
  #
  def fetch_facebook_comments(product)
    url = product.fb_comments_url
    request = Typhoeus::Request.new(url) 

    request.on_complete do |response|
      begin
        @comments[product.id] = JSON.parse(response.body)
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

end
