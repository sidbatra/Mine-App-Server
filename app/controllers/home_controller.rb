class HomeController < ApplicationController

  def show
    @products = Product.find_all_by_id([1,10,110,150])
  end

end
