class PurchasesController < ApplicationController
  before_filter :login_required, :except => :show

  # Fetch a set of purchases for a particular user.
  #
  # params[:user_id] - The Integer id of the user whose purchases
  #                     are to be fetched.
  # params[:after] - Integer(Unix timestamp). Only fetch feed items 
  #                   created after the given timestamp.
  # params[:before] - Integer(Unix timestamp). Only fetch feed items 
  #                   created before the given timestamp.
  # params[:per_page] - Integer:10. The number of feed items per page.
  # 
  # List of purchases with the following aspects.
  #
  # params[:aspect]:
  #   user  - requires params[:user_id]. Purchases  by the given 
  #           users with pagination options. Default.
  #   unapproved - Unapproved purchases for the current user with
  #                pagination options.
  #   unapproved_ui - UI for displaying unapproved purchases.
  #
  def index
    @aspect = params[:aspect] ? params[:aspect].to_sym : :user
    @purchases = []
    @key = ""
    @cache_options = {}


    case @aspect
    when :user
      @user = User.find params[:user_id]

      @after = params[:after] ? Time.at(params[:after].to_i) : nil
      @before = params[:before] ? Time.at(params[:before].to_i) : nil
      @per_page = params[:per_page] ? params[:per_page].to_i : 10

      @key = ["v2",@user,"purchases",@before ? @before.to_i : "",@per_page]

      @purchases = Purchase.
                    select(:id,:bought_at,:title,:handle,:source_url,
                            :orig_thumb_url,:orig_image_url,:endorsement,
                            :image_path,:is_processed,:user_id,:store_id,
                            :fb_action_id).
                    approved.
                    with_user.
                    with_store.
                    with_comments.
                    with_likes.
                    by_bought_at.
                    bought_after(@after).
                    bought_before(@before).
                    limit(@per_page).
                    for_users([@user]) unless fragment_exist? @key

    when :unapproved_ui 

    when :unapproved
      @after = params[:after] ? Time.at(params[:after].to_i) : nil
      @before = params[:before] ? Time.at(params[:before].to_i) : nil
      @per_page = params[:per_page] ? params[:per_page].to_i : 10
      @on_bought = params[:by_created_at] ? false : true

      @purchases = Purchase.
                    select(:id,:bought_at,:title,:handle,:source_url,
                            :orig_thumb_url,:orig_image_url,:endorsement,
                            :image_path,:is_processed,:user_id,:store_id,
                            :fb_action_id).
                    unapproved.
                    with_user.
                    with_store.
                    with_comments.
                    with_likes.
                    page(@after,@before,@on_bought).
                    limit(@per_page).
                    for_users([self.current_user]) 
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html
      format.json 
    end
  end

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

    #if params[:purchase][:source_purchase_id] && params[:purchase][:clone]
    #  populate_params_from_purchase
    #end

    if params[:purchase][:is_store_unknown] == '0'
      params[:purchase][:store_id] = Store.add(
                                      params[:purchase][:store_name],
                                      self.current_user.id).id
    end


    setting = self.current_user.setting

    unless params[:purchase][:share_to_facebook].nil?
      setting.share_to_facebook = params[:purchase][:share_to_facebook]
    end

    unless params[:purchase][:share_to_twitter].nil?
      setting.share_to_twitter = params[:purchase][:share_to_twitter]
    end

    unless params[:purchase][:share_to_tumblr].nil?
      setting.share_to_tumblr = params[:purchase][:share_to_tumblr]
    end

    setting.save!


    if setting.post_to_facebook?
      params[:purchase][:fb_action_id] = FBSharing::Underway
    end

    if setting.post_to_twitter?
      params[:purchase][:tweet_id] = TWSharing::Underway
    end
    
    if setting.post_to_tumblr?
      params[:purchase][:tumblr_post_id] = TumblrSharing::Underway
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
    
    if params[:purchase_id]
      @purchase = Purchase.
                    approved.
                    with_comments.
                    with_likes.
                    find_by_id Cryptography.deobfuscate(params[:purchase_id])
    else
      user = User.find_by_handle params[:user_handle]

      @purchase = Purchase.
                    approved.
                    with_comments.
                    with_likes.
                    find_by_user_id_and_handle(
                     user.id,
                     params[:purchase_handle]) if user
    end

    if is_request_html? && @purchase
      track_visit
      populate_theme @purchase.user

      #@next_purchase = @purchase.next
      #@next_purchase ||= @purchase.user.purchases.first

      #@prev_purchase = @purchase.previous
      #@prev_purchase ||= @purchase.user.purchases.last

      @origin = 'purchase'
    end

  rescue => ex
    handle_exception(ex)
  ensure
    raise_not_found unless @purchase

    respond_to do |format|
      format.html
      format.json 
    end
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
    respond_to do |format|
      format.html do 
        redirect_to user_path(
                      self.current_user.handle,
                      :src => UserShowSource::PurchaseDeleted)
      end
      format.json
    end
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
