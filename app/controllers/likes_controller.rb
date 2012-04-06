class LikesController < ApplicationController
  before_filter :login_required

  # List of facebook likes for products pushed to gallery or timeline
  # 
  # params[:product_ids] - Comma separated list for all product 
  #                        ids whose likes need to be fetched
  #
  def index
    @likes = [] 
    product_ids = params[:product_ids].split(",")
    products    = Product.find_all_by_id(product_ids, :include => :user)
   
    hydra = Typhoeus::Hydra.new

    products.each do |product|
      hydra.queue fetch_facebook_likes(product) if product.fb_object_id 
    end

    hydra.run
    
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Create a new like on facebook
  #
  def create
    product  = Product.find(params[:product_id]) 
    fb_post  = product.fb_post

    @like = nil
    
    if fb_post
      like = fb_post.like!(:access_token => self.current_user.access_token) 

      @like = {:product_id  => product.id,
               :user_id     => self.current_user.fb_user_id,
               :name        => self.current_user.full_name} if like
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  protected

  # Fetch facebook likes for a particular product
  #
  def fetch_facebook_likes(product)
    url = product.fb_likes_url
    request = Typhoeus::Request.new(url) 

    request.on_complete do |response|
      begin
        data = JSON.parse(response.body)['data']

        data.each do |d| 
          d['product_id'] = product.id
          d['user_id']    = d['id']
        end

        @likes += data
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

end
