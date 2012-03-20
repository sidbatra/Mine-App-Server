# Receive delayed events on the collection model
#
class CollectionDelayedObserver < DelayedObserver

  # Delayed after_update
  #
  def self.after_update(collection_id,options={})
    collection = Collection.find(collection_id)
    collection.process if options[:reprocess]
    
    DistributionManager.update_object(
                          collection_url(
                            collection.user.handle,
                            collection.handle,
                            :host => CONFIG[:host]))
  end

end
