# Handle requests for the home page
#
class HomeController < ApplicationController

  # Display pre-selected products on the home page
  #
  def show
    @campaign = params[:id]
    @products = Product.eager.find_all_by_id([1,2,3,4,5,6])
  end

end
