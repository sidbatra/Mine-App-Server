# Handle requests for the products resource
#
class ProductsController < ApplicationController
  before_filter :login_required, :only => [:new,:create]

  # Display UI for creating a new product
  #
  def new
    @product = Product.new
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Create a new product
  #
  def create
    product     = Product.add(
                            params[:product],
                            self.current_user.id);

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

end
