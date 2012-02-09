# Observe events on the Collection model
#
class CollectionObserver < ActiveRecord::Observer

  # Ping notification manager when a new collection
  # is added
  #
  def after_create(collection)
    ProcessingQueue.push(
      NotificationManager,
      :new_collection,
      collection.id)
  end
end
