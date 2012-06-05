class LikesController < ApplicationController
  before_filter :login_required, :except => :index

  # List of facebook likes for purchases pushed to gallery or timeline
  # 
  # params[:purchase_ids] - Comma separated list for all purchase 
  #                        ids whose likes need to be fetched
  #
  def index
    purchase_ids = params[:purchase_ids].split(",")
    purchases    = Purchase.find_all_by_id(purchase_ids)

    @likes       = Like.with_user.find_all_by_purchase_id(purchase_ids) 
   
    hydra = Typhoeus::Hydra.new

    purchases.each do |purchase|
      hydra.queue fetch_facebook_likes(purchase) if purchase.shared?
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
    purchase = Purchase.find(params[:purchase_id]) 
    @like   = nil
    
    if purchase.shared? 
      like = purchase.fb_post.like!(
              :access_token => self.current_user.access_token) 

      @like = {:purchase_id => purchase.id,
               :fb_user_id  => self.current_user.fb_user_id,
               :name        => self.current_user.full_name,
               :id          => SecureRandom.hex(10)} if like
    
    elsif purchase.native?
      like = Like.add(purchase.id,self.current_user.id)

      @like = {:purchase_id => purchase.id,
               :fb_user_id  => self.current_user.fb_user_id,
               :name        => self.current_user.full_name,
               :id          => like.id} 
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  protected

  # Fetch facebook likes for a particular purchase
  #
  def fetch_facebook_likes(purchase)
    url = purchase.fb_likes_url(self.current_user.access_token)
    request = Typhoeus::Request.new(url) 

    request.on_complete do |response|
      begin
        json  = JSON.parse(response.body)
        id    = json['id']
        error = json['error']

        if error 
          purchase.deleted_from_fb

          data = [{'purchase_id'  => purchase.id,
                   'error'        => true}]
        else
          data = json['likes']['data']
            
          data.each do |d| 
            d['purchase_id'] = purchase.id
            d['fb_user_id']  = d['id']
          end
        end

        @likes += data

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

end
