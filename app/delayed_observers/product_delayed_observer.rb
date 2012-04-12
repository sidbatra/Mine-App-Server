class ProductDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(product_id)
    product = Product.find(product_id)
    product.host

    if product.user.setting.post_to_timeline?
      DistributionManager.publish_add(product)
    end
  end

  # Delayed after_update.
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
