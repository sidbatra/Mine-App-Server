class ProductsController < ApplicationController
  before_filter :login_required, :except => :show

  # Create a new product.
  #
  # There are two different ways of using /products [POST].
  #
  # The straightforward way is to pass all relevant params
  # inside the params hash.
  #
  # The other way is to create a product from an existing one with
  # a different store name. This requires passing a :source_product_id 
  # param with the id of the original product and an optional store_name.
  #
  def create

    if params[:product][:source_product_id] && params[:product][:clone]
      populate_params_from_product
    end

    if params[:product][:is_store_unknown] == '0'
      params[:product][:store_id] = Store.add(
                                      params[:product][:store_name],
                                      self.current_user.id).id
    end

    @product = Product.add(params[:product],self.current_user.id)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

  # Display a specific product.
  #
  def show
    user = User.find_by_handle(params[:user_handle])

    @product = Product.find_by_user_id_and_handle(
                 user.id,
                 params[:product_handle])

    @next_product  = @product.next
    @next_product  ||= @product.user.products.first

    @prev_product  = @product.previous
    @prev_product  ||= @product.user.products.last

  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Display page for editing a product.
  #
  def edit
    user = User.find_by_handle(params[:user_handle])

    raise IOError, "Unauthorized Access" if user.id != self.current_user.id


    @product = Product.find_by_user_id_and_handle(
                user.id,
                params[:product_handle])

    if @product.store
      @product.store_name = @product.store.name 
      @product.is_store_unknown = false
    else
      @product.store_name = ''
      @product.is_store_unknown = true
    end

    @suggestion = @product.suggestion

  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Update a product.
  #
  def update
    @product = Product.find(params[:id])
    product_params = params[:product]

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

  # Destroy a product.
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
  def populate_params_from_product
    product = Product.find(params[:product][:source_product_id])

    params[:product][:title]          = product.title
    params[:product][:source_url]     = product.source_url
    params[:product][:orig_image_url] = product.image_url
    params[:product][:orig_thumb_url] = product.thumbnail_url
    params[:product][:query]          = product.query
    params[:product][:endorsement]    = ''

    params
  end

end
