# Handle requests for the shopping resource
#
class ShoppingsController < ApplicationController
  before_filter :login_required

  # Display UI for creating one or multiple shoppings 
  #
  def new
    @shopping = Shopping.new
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Create one or more shoppings 
  #
  def create
    store_ids = params[:store_ids].split(',')

    store_ids.each do |store_id|
      Shopping.add(
        self.current_user.id,
        store_id,
        ShoppingSource::User)
    end

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to user_path(
                  self.current_user.handle,
                  :src    => @error ?
                              UserShowSource::ShoppingsCreateError :
                              UserShowSource::ShoppingsCreate,
                  :anchor => UserShowHash::Owns)
  end

end
