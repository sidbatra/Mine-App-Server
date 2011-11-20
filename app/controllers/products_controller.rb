# Handle requests for the products resource
#
class ProductsController < ApplicationController
  before_filter :login_required,  :only => [:new,:create,:edit,:update,:destroy]
  before_filter :logged_in?,      :only => :show

  # Display UI for creating a new product
  #
  def new
    @source       = params[:src] ? params[:src].to_s : "direct"

    @product      = Product.new

    @category     = Category.fetch(
                      params[:category] ? params[:category] : "anything")

    @placeholders = MSG[:product][@category.handle.to_sym]
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Create a new product
  #
  def create
    
    if params[:product][:source_product_id]
      params[:product] = populate_params_from_product(params[:product])
    end

    if params[:product][:is_store_unknown] == '0'
      params[:product][:store_id] = Store.add(
                                      params[:product][:store_name],
                                      self.current_user.id).id
    end

    if params[:product][:is_gift] == '1'
      params[:product][:price] = 0 if params[:product][:price].nil?
    end

    @product  = Product.add(params[:product],self.current_user.id)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
      format.html do
        redirect_to  @error ? 
                      new_product_path(
                        :category => Category.find(
                                        params[:product][:category_id]).handle,
                        :src      => 'error') :
                      user_path(
                        self.current_user.handle,
                        :src => 'product_create')

      end
    end
  end

  # Fetch multiple products
  #
  def index
    @filter   = params[:filter].to_sym
    @options  = {}

    case @filter
    when :user
      @category = Category.fetch(params[:category]) if params[:category]
      @products = Product.with_store.with_user.
                    for_user(params[:owner_id]).
                    in_category(@category ? @category.id : nil).
                    by_id

      @options[:with_store] = true
      @options[:with_user]  = true
    when :store
      @category = Category.fetch(params[:category]) if params[:category]
      @products = Product.with_user.
                    for_store(params[:owner_id]).
                    in_category(@category ? @category.id : nil).
                    by_id

      @options[:with_user] = true
    when :top
      @products = Product.top_for_store(params[:owner_id])

      @options[:with_user] = true
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


    @source   = params[:src] ? params[:src].to_s : "direct"

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
    redirect_to root_path(:src => 'product_show_error') if @error
  end

  # Display form for editing a product
  #
  def edit
    @source       = params[:src] ? params[:src].to_s : "direct"

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
    @placeholders = MSG[:product][@category.handle.to_sym]

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to root_path(:src => 'product_edit_error') if @error
  end

  # Update user's byline
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

    if product_params[:is_gift] && 
        product_params[:is_gift] == '1'

      product_params[:price] = 0 if product_params[:price].nil?
    end


    if @product.user_id == self.current_user.id
      @product.update_attributes(product_params) 
    end
  
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
      format.html do 
        redirect_to product_path(
                    self.current_user.handle,
                    @product.handle,
                    :src => 'product_updated')
      end
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
    redirect_to user_path(self.current_user.handle,:src => "product_deleted")
  end


  protected

  # Populate params from the given product's source id
  #
  def populate_params_from_product(params)
    product = Product.find(params[:source_product_id])

    params[:title]          = product.title
    params[:source_url]     = product.source_url
    params[:orig_image_url] = product.orig_image_url
    params[:orig_thumb_url] = product.orig_thumb_url
    params[:is_hosted]      = 0
    params[:query]          = product.query
    params[:category_id]    = product.category_id
    params[:endorsement]    = ''

    params
  end

  # Prepare parameters for the image uploder
  #
  def generate_uploader
    uploader = {}
    uploader[:server]     = "http://#{CONFIG[:s3_bucket]}.s3.amazonaws.com/"
    uploader[:aws_id]     = CONFIG[:aws_access_id]
    uploader[:max]        = 50.megabytes
    uploader[:extensions] = "*.jpeg;*.jpg;*.gif;*.bmp;*.png"
    uploader[:key]        = [Time.now.to_i,SecureRandom.hex(20)].join("_")
    uploader[:policy]     = Base64.encode64(
                              "{'expiration': '#{6.year.from_now.
                                  utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')}',
                                'conditions': [
                                  {'bucket': '#{CONFIG[:s3_bucket]}'},
                                  {'acl': 'public-read'},
                                  {'success_action_status': '201'},
                                  ['content-length-range',0, #{uploader[:max]}],
                                  ['starts-with', '$key', '#{uploader[:key]}'],
                                  ['starts-with', '$Filename', '']
                                ]
                              }").gsub(/\n|\r/, '')
    uploader[:signature]   = Base64.encode64(
                              OpenSSL::HMAC.digest(
                                OpenSSL::Digest::Digest.new('sha1'),
                                CONFIG[:aws_secret_key],
                                uploader[:policy])).gsub("\n","")
    uploader
  end

end
