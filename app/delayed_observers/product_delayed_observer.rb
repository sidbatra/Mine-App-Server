class ProductDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(product_id)
    product = Product.find(product_id)
    product.host

    if product.share_to_fb_timeline? 
      DistributionManager.publish_add(product)
    end

    if product.share_to_fb_album? 
      DistributionManager.publish_product_to_fb_album(product)
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
