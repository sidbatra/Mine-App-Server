# Observe events on the Store model
#
class StoreObserver < ActiveRecord::Observer

  # New store is created
  #
  def after_create(store)
  end

  # Store is going to be updated
  #
  def before_update(store)
    if store.image_path_changed?
      store.rehost        = true
      store.is_processed  = false
    end
  end

  # A store is updated
  #
  def after_update(store)
    ProcessingQueue.push(
      NotificationManager,
      :update_store,
      store.id) if store.rehost
  end

  # A store is delted
  #
  def after_destroy(store)
  end


end
