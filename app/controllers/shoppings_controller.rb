# Handle requests for the shopping resource
#
class ShoppingsController < ApplicationController
  before_filter :login_required

  # Display UI for creating new shoppings 
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
    store_ids = params[:shopping][:store_ids].split(',')

    store_ids.each do |store_id|
      Shopping.add(self.current_user.id,store_id,ShoppingSource::User)
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do
        redirect_to  @error ? 
                      new_shopping_path(
                        :src => 'error') :
                      new_following_path(
                        :src => 'login')
      end
      format.json 
    end
  end

end
