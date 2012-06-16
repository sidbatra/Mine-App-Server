class PurchaseDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(purchase_id)
    purchase = Purchase.find(purchase_id)
    purchase.host

    if purchase.share_to_fb_timeline? && purchase.is_processed
      DistributionManager.publish_share(purchase)
    end

    if purchase.share_to_twitter? && purchase.is_processed
      DistributionManager.tweet(purchase)
    end

    if purchase.share_to_tumblr? && purchase.is_processed
      DistributionManager.post_to_tumblr(purchase)
    end
  end

  # Delayed after_update.
  #
  def self.after_update(purchase_id,options={})
    purchase = Purchase.find(purchase_id)
    purchase.host if options[:rehost]
    
    if purchase.shared? && purchase.is_processed
      DistributionManager.update_object(
                            purchase_url(
                              purchase.user.handle,
                              purchase.handle,
                              :host => CONFIG[:host]))
    end
  end

end
