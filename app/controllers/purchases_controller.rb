class PurchasesController < ApplicationController
  before_filter :login_required, :except => :show

  # Create a new purchase.
  #
  # There are two different ways of using /purchases [POST].
  #
  # The straightforward way is to pass all relevant params
  # inside the params hash.
  #
  # The other way is to create a purchase from an existing one with
  # a different store name. This requires passing a :source_purchase_id 
  # param with the id of the original purchase and an optional store_name.
  #
  def create

    if params[:purchase][:product]
      product = Product.find_by_orig_image_url(
                  params[:purchase][:orig_image_url])
      params[:purchase][:product_id] = product.id if product
    end

    #if params[:purchase][:source_purchase_id] && params[:purchase][:clone]
    #  populate_params_from_purchase
    #end

    if params[:purchase][:is_store_unknown] == '0'
      params[:purchase][:store_id] = Store.add(
                                      params[:purchase][:store_name],
                                      self.current_user.id).id
    end

    setting = self.current_user.setting

    unless params[:purchase][:post_to_timeline].nil?
      setting.post_to_timeline = params[:purchase][:post_to_timeline]
      setting.save!
    end

    unless params[:purchase][:share_to_twitter].nil?
      setting.share_to_twitter = params[:purchase][:share_to_twitter]
      setting.save!
    end

    unless params[:purchase][:share_to_tumblr].nil?
      setting.share_to_tumblr = params[:purchase][:share_to_tumblr]
      setting.save!
    end

    if setting.post_to_timeline?
      params[:purchase][:fb_action_id] = FBSharing::Underway
    end

    if setting.post_to_twitter?
      params[:purchase][:tweet_id] = TWSharing::Underway
    end
    
    if setting.post_to_tumblr?
      #params[:purchase][:tumblr_id] = TumblrSharing::Underway
    end

    @purchase = Purchase.add(params[:purchase],self.current_user.id)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Display a specific purchase.
  #
  def show
    track_visit
    
    if params[:purchase_id]
      @purchase = Purchase.find(Cryptography.deobfuscate params[:purchase_id])
    else
      user = User.find_by_handle(params[:user_handle])

      @purchase = Purchase.find_by_user_id_and_handle(
                   user.id,
                   params[:purchase_handle])
    end

    #@next_purchase = @purchase.next
    #@next_purchase ||= @purchase.user.purchases.first

    #@prev_purchase = @purchase.previous
    #@prev_purchase ||= @purchase.user.purchases.last

    @origin = 'purchase'

  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Display page for editing a purchase.
  #
  def edit
    user = User.find_by_handle(params[:user_handle])

    raise IOError, "Unauthorized Access" if user.id != self.current_user.id


    @purchase = Purchase.find_by_user_id_and_handle(
                user.id,
                params[:purchase_handle])

    if @purchase.store
      @purchase.store_name = @purchase.store.name 
      @purchase.is_store_unknown = false
    else
      @purchase.store_name = ''
      @purchase.is_store_unknown = true
    end

    @suggestion = @purchase.suggestion

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to(root_path) if @error
  end

  # Update a purchase.
  #
  def update
    @purchase = Purchase.find(params[:id])
    purchase_params = params[:purchase]

    purchase_params[:user_id] = self.current_user.id


    if purchase_params[:is_store_unknown] 
      purchase_params[:store_id] = purchase_params[:is_store_unknown] == '0' ? 
                                    Store.add(
                                        purchase_params[:store_name],
                                        self.current_user.id).id :
                                    nil
    end

    if @purchase.user_id == self.current_user.id
      @purchase.update_attributes(purchase_params) 
    end

    flash[:updated] = true

  rescue => ex
    handle_exception(ex)
    flash[:updated] = false
  ensure
    respond_to do |format|
      format.html do 
        redirect_to edit_purchase_path(
                      self.current_user.handle,
                      @purchase.handle,
                      :src => PurchaseEditSource::Updated)
      end
      format.json 
    end
  end

  # Destroy a purchase.
  #
  def destroy
    purchase = Purchase.find(params[:id])
    purchase.destroy if purchase.user_id == self.current_user.id

    flash[:destroyed] = true
  rescue => ex
    handle_exception(ex)
    flash[:destroyed] = false
  ensure
    redirect_to user_path(
                  self.current_user.handle,
                  :src => UserShowSource::PurchaseDeleted)
  end


  protected

  # Populate params from the given purchase's source id
  #
  #def populate_params_from_purchase
  #  purchase = Purchase.find(params[:purchase][:source_purchase_id])

  #  params[:purchase][:title]          = purchase.title
  #  params[:purchase][:source_url]     = purchase.source_url
  #  params[:purchase][:orig_image_url] = purchase.image_url
  #  params[:purchase][:orig_thumb_url] = purchase.thumbnail_url
  #  params[:purchase][:query]          = purchase.query

  #  params
  #end

end
