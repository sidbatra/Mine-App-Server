# Observe events on the Store model
#
class StoreObserver < ActiveRecord::Observer

  # New store is created
  #
  def after_create(store)
    Cache.delete(KEYS[:store_all])
  end

  # A store is updated
  #
  def after_update(store)
    Cache.delete(KEYS[:store_all])
    Cache.delete(KEYS[:store_top])
  end

  # A store is delted
  #
  def after_destroy(store)
    Cache.delete(KEYS[:store_all])
    Cache.delete(KEYS[:store_top])
  end


end
