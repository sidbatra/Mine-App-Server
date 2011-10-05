# Handle requests for the products resource
#
class ProductsController < ApplicationController
  before_filter :login_required, :only => [:new,:create]

  # Display UI for creating a new product
  #
  def new
  end

  # Create a new product
  #
  def create
  end

  # Display a product
  #
  def show
  end

end
