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
    product = Product.add(params[:product],self.current_user.id);
    raise params.to_yaml
  #rescue => ex
  #  handle_exception(ex)
  #ensure
  end

  # Display a product
  #
  def show
  rescue => ex
    handle_exception(ex)
  ensure
  end

end
