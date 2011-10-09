# Handle requests for creating shares
#
class ShareController < ApplicationController
  before_filter :login_required
  
  # Create a new share for a product
  #
  def create
    product = Product.eager.find(params[:product_id])

    if product && product.user.id == self.current_user.id && 
        !product.is_shared

      product.shared

      self.current_user.share_product(
                          product,
                          product_url(
                            product.id,
                            product.handle)) 
      
    end
  rescue => ex
    handle_exception(ex)
  ensure
    render :text => "{'status': 'done'}"
  end


end
