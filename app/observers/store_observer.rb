# Observe events on the Store model
#
class StoreObserver < ActiveRecord::Observer

  # New store is created
  #
  def after_create(store)
  end

  # A store is updated
  #
  def after_update(store)
  end

  # A store is delted
  #
  def after_destroy(store)
  end


end
