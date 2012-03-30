class StoreDelayedObserver < DelayedObserver

  # Delayed after_update.
  #
  def self.after_update(store_id,options={})
    store = Store.find(store_id)

    store.host if options[:rehost]
    store.update_domain if options[:reupdate_domain]
    store.update_metadata if options[:reupdate_metadata]
    
    #DistributionManager.update_object(
    #                      store_url(
    #                        store.handle,
    #                        :host => CONFIG[:host]))
  end

end
