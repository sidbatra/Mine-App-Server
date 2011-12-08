# Oberve events on various models to keep the Store cache
# persistent 
#
class StoreSweeper < ActionController::Caching::Sweeper
  observe Store

  # Fired when a store is created
  #
  def after_create(store)
  end

  # Fired when a store is updated
  #
  def after_update(store)
  end
end
