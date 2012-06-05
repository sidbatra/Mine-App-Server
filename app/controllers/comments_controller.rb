class CommentsController < ApplicationController
  before_filter :login_required

  # List of facebook comments for purchases pushed to gallery or timeline
  # 
  # params[:purchase_ids] - Comma separated list for all purchase 
  #                        ids whose comments need to be fetched
  #
  def index
    purchase_ids  = params[:purchase_ids].split(",")
    purchases     = Purchase.find_all_by_id(purchase_ids)

    @comments     = Comment.with_user.find_all_by_purchase_id(purchase_ids) 
   
    hydra = Typhoeus::Hydra.new

    purchases.each do |purchase|
      hydra.queue fetch_facebook_comments(purchase) if purchase.shared?
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
    purchase  = Purchase.find(params[:purchase_id]) 
    @comment  = nil
    
    if purchase.shared? 
      comment = purchase.fb_post.comment!(
                  :message      => params[:message],
                  :access_token => self.current_user.access_token)

      @comment = {:purchase_id  => purchase.id,
                  :id           => comment.identifier,
                  :messsage     => comment.message,
                  :from         => {:name => self.current_user.full_name,
                                    :id   => self.current_user.fb_user_id}}

    elsif purchase.native?
      comment = Comment.add(params,self.current_user.id) 

      @comment = {:purchase_id  => comment.purchase_id,
                  :id           => comment.id,
                  :messsage     => comment.message,
                  :from         => {:name => self.current_user.full_name,
                                    :id   => self.current_user.fb_user_id}}
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  protected

  # Fetch facebook comments for a particular purchase
  #
  def fetch_facebook_comments(purchase)
    url = purchase.fb_comments_url(self.current_user.access_token)
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
          data = json['comments']['data']
            
          data.each do |d| 
            d['purchase_id'] = purchase.id
          end
        end
        
        @comments += data 
          
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

    request
  end

end
