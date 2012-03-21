# Receive delayed events on the product model
#
class ProductDelayedObserver < DelayedObserver

  # Delayed after_update
  #
  def self.after_update(product_id,options={})
    product = Product.find(product_id)
    product.host if options[:rehost]
    
    DistributionManager.update_object(
                          product_url(
                            product.user.handle,
                            product.handle,
                            :host => CONFIG[:host]))
  end

end
