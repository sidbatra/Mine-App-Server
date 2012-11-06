class StoreObserver < ActiveRecord::Observer

  # Build crawl datum for the store about to be created.
  #
  def before_create(store)
    store.build_crawl_datum
    store.build_email_parse_datum
  end

  # Test the store object for the following events:
  #   rehosting - if image path is changed
  #   domain update - if the store has just been approved
  #   metadata update - if the store domain has changed.
  #
  def before_update(store)
    if store.image_path_changed?
      store.rehost = true
      store.is_processed  = false
    end

    store.reupdate_domain = store.is_approved_changed? && 
                              store.is_approved &&
                              !store.domain_changed?

    store.reupdate_metadata = store.domain_changed? && 
                                store.domain.present?
  end

  # Hand over to the delayed observer with conditional
  # event triggers.
  #
  def after_update(store)
    ProcessingQueue.push(
      StoreDelayedObserver,
      :after_update,
      store.id,
      :rehost => store.rehost,
      :reupdate_domain => store.reupdate_domain,
      :reupdate_metadata => store.reupdate_metadata) 
  end

end
