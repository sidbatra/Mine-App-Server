class PurchaseDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(purchase_id)
    purchase = Purchase.find(purchase_id)
    purchase.host

    if purchase.share_to_fb_album? 
      DistributionManager.publish_purchase_to_fb_album(purchase)
    end

    if purchase.share_to_fb_timeline? 
      DistributionManager.publish_add(purchase)
    end
  end

  # Delayed after_update.
  #
  def self.after_update(purchase_id,options={})
    purchase = Purchase.find(purchase_id)
    purchase.host if options[:rehost]
    
    DistributionManager.update_object(
                          purchase_url(
                            purchase.user.handle,
                            purchase.handle,
                            :host => CONFIG[:host]))
  end

end
