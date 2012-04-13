class ProductDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(product_id,post_to_timeline,post_to_fb_album)
    product = Product.find(product_id)
    product.host

    if post_to_timeline
      DistributionManager.publish_add(product)
    end

    if post_to_fb_album
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
