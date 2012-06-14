class PurchaseDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(purchase_id)
    purchase = Purchase.find(purchase_id)
    purchase.host

    if purchase.share_to_fb_timeline? && purchase.is_processed
      DistributionManager.publish_share(purchase)
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
