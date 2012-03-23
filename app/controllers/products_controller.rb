# Handle requests for the products resource
#
class ProductsController < ApplicationController
  before_filter :login_required,  :only => [:new,:create,:edit,:update,:destroy]
  before_filter :renew_session, :only => :show

  # Display UI for creating a new product
  #
  def new
    @product        = Product.new
    @product.price  = 0

    @category     = Category.fetch(
                      params[:category] ? params[:category] : "anything")

    @suggestion   = params[:suggestion] ? 
                      Suggestion.find(params[:suggestion]) : nil

    @store        = params[:store] ? 
                      Store.find_by_handle(params[:store]) : nil

    @product.store_name = @store.name if @store

    @placeholders = MSG[:product][@category.handle.to_sym]
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Create a new product
  #
  def create
    
    if params[:product][:source_product_id] && params[:product][:clone]
      params[:product] = populate_params_from_product(params[:product])
    end

    if params[:product][:is_store_unknown] == '0'
      params[:product][:store_id] = Store.add(
                                      params[:product][:store_name],
                                      self.current_user.id).id
    end

    @product  = Product.add(params[:product],self.current_user.id)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do
        redirect_to  @error ? 
                      new_product_path(
                        :src => ProductNewSource::Error) :
                      user_path(
                        self.current_user.handle,
                        :src    => UserShowSource::ProductCreate,
                        :anchor => UserShowHash::Owns)

      end
      format.json 
    end
  end

  # Fetch multiple products
  #
  def index
    @filter     = params[:filter].to_sym

    category    = Category.fetch(params[:category]) if params[:category]
    category_id = category ? category.id : nil

    case @filter
    when :user
      @products   = Product.select(:id,:is_gift,:handle,:user_id,:store_id,
                              :image_path,:is_hosted,
                              :is_processed,:orig_thumb_url).
                      with_store.
                      with_user.
                      for_user(params[:owner_id]).
                      in_category(category_id).
                      by_id

      @key = KEYS[:user_products_in_category] % [params[:owner_id],category_id]

    when :store
      @products   = Product.select(:id,:is_gift,:handle,:user_id,
                              :image_path,:is_hosted,
                              :is_processed,:orig_thumb_url).
                      with_user.
                      for_store(params[:owner_id]).
                      in_category(category_id).
                      by_id

      @key = KEYS[:store_products_in_category] % [params[:owner_id],category_id]

    when :top
      @products = Product.select(:id,:title,:handle,:user_id).
                    for_store(params[:owner_id]).
                    created(30.days.ago..Time.now).
                    by_actions.
                    with_user.
                    limit(10)

      @key = KEYS[:store_top_products] % params[:owner_id]

    when :used
      @products = Product.for_user(params[:owner_id]).
                    with_user.
                    most_used.
                    limit(10)

      @key = KEYS[:user_top_products] % params[:owner_id]

    when :wanted
      @products = Product.select('products.id',:is_gift,:handle,
                              'products.user_id',:store_id,
                              :category_id,:image_path,:is_hosted,
                              :is_processed,:orig_thumb_url).
                    with_store.
                    with_user.
                    acted_on_by_for(params[:owner_id],ActionName::Want).
                    in_category(category_id)
      
      @key = KEYS[:user_want_products_in_category] % 
              [params[:owner_id],category_id]

    else
      raise IOError, "Invalid option"
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Display a product
  #
  def show

    if params[:id].present?
      product = Product.find(params[:id])
      redirect_to product_path(product.user.handle,product.handle)
      return
    end


    user      = User.find_by_handle(params[:user_handle])
    @product  = Product.with_store.with_user.find_by_user_id_and_handle(
                          user.id,
                          params[:product_handle])


    @next_product  = @product.next
    @next_product  ||= @product.user.products.first

    @prev_product  = @product.previous
    @prev_product  ||= @product.user.products.last

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to root_path if @error
  end

  # Display form for editing a product
  #
  def edit
    user          = User.find_by_handle(params[:user_handle])

    raise IOError, "Unauthorized Access" if user.id != self.current_user.id


    @product      = Product.with_store.find_by_user_id_and_handle(
                              user.id,
                              params[:product_handle])

    if @product.store
      @product.store_name = @product.store.name 
      @product.is_store_unknown = false
    else
      @product.store_name = ''
      @product.is_store_unknown = true
    end


    @category     = @product.category
    @suggestion   = @product.suggestion
    @placeholders = MSG[:product][@category.handle.to_sym]

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to root_path if @error
  end

  # Update product
  #
  def update
    @product        = Product.find(params[:id])
    product_params  = params[:product]

    product_params[:user_id] = self.current_user.id


    if product_params[:is_store_unknown] 
      product_params[:store_id] = product_params[:is_store_unknown] == '0' ? 
                                    Store.add(
                                        product_params[:store_name],
                                        self.current_user.id).id :
                                    nil
    end

    if @product.user_id == self.current_user.id
      @product.update_attributes(product_params) 
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do 
        redirect_to product_path(
                    self.current_user.handle,
                    @product.handle,
                    :src => ProductShowSource::Updated)
      end
      format.json 
    end
  end

  # Destroy a product if the curernt user has proper permissions
  #
  def destroy
    product = Product.find(params[:id])
    product.destroy if product.user_id == self.current_user.id
  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to user_path(
                  self.current_user.handle,
                  :src    => UserShowSource::ProductDeleted,
                  :anchor => UserShowHash::Owns)
  end


  protected

  # Populate params from the given product's source id
  #
  def populate_params_from_product(params)
    product = Product.find(params[:source_product_id])

    params[:title]          = product.title
    params[:source_url]     = product.source_url
    params[:orig_image_url] = product.image_url
    params[:orig_thumb_url] = product.thumbnail_url
    params[:is_hosted]      = 0
    params[:query]          = product.query
    params[:category_id]    = product.category_id
    params[:endorsement]    = ''

    params
  end

end
