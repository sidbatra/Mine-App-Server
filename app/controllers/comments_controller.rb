class CommentsController < ApplicationController
  before_filter :login_required

  # List of facebook comments for products pushed to gallery or timeline
  # 
  # params[:product_ids] - Comma separated list for all product 
  #                        ids whose comments need to be fetched
  #
  def index
    @comments   = []
    product_ids = params[:product_ids].split(",")
    products    = Product.find_all_by_id(product_ids, :include => :user)
   
    hydra = Typhoeus::Hydra.new

    products.each do |product|
      hydra.queue fetch_facebook_comments(product) if product.shared?
    end

    hydra.run
    
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Create a new comment on facebook
  #
  def create
    product  = Product.find(params[:product_id]) 
    @comment = nil
    
    if product.shared? 
      comment = product.fb_post.comment!(
                  :message      => params[:message],
                  :access_token => self.current_user.access_token)

      @comment = {:product_id   => product.id,
                  :id           => comment.identifier,
                  :messsage     => comment.message,
                  :from         => {:name => self.current_user.full_name,
                                    :id   => self.current_user.fb_user_id},
                  :created_time => Time.now}
    end
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
        data = JSON.parse(response.body)['data']

        if data
          data.each do |d| 
            d['product_id'] = product.id
          end
          @comments += data 
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

end
