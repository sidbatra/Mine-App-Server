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

  # Reprocess collection after an update
  #
  def after_update(collection)
    ProcessingQueue.push(
      NotificationManager,
      :update_collection,
      collection.id) if collection.reprocess
  end
end
