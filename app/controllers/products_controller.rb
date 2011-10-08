# Handle requests for the products resource
#
class ProductsController < ApplicationController
  before_filter :login_required, :only => [:new,:create]

  # Display UI for creating a new product
  #
  def new
    @product  = Product.new
    @uploader = generate_uploader
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Create a new product
  #
  def create
    product     = Product.add(
                            params[:product],
                            self.current_user.id)

    #self.current_user.share_product(
    #                    product,
    #                    product_url(
    #                      product.id,
    #                      product.handle))

    target_url  = product_path(
                   product.id,
                   product.handle)


  rescue => ex
    handle_exception(ex)
    target_url = new_product_path
  ensure
    redirect_to target_url
  end

  # Display a product
  #
  def show
    @product = Product.eager.find(params[:id])

    redirect_to product_path(
                  @product.id,
                  @product.handle) if params[:name] != @product.handle
  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to root_path if @error
  end


  protected

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
