# Oberve events on various models to keep the Store cache
# stores persistent 
#
class StoreSweeper < ActionController::Caching::Sweeper
  observe Store

  # Store is created
  #
  def after_create(store)
    expire_all_store
  end

  # Store is updated
  #
  def after_update(store)
    expire_top_store
    expire_all_store
  end

  # Store is deleted
  #
  def after_destroy(store)
    expire_top_store
    expire_all_store
  end

  # Expire cache fragment for top stores
  #
  def expire_top_store
    expire_cache KEYS[:store_top]
  end

  # Expire cache fragment for all stores
  #
  def expire_all_store
    expire_cache KEYS[:store_all]
  end
end
