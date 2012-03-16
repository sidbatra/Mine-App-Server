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

  # Delete facebook stories after a collection
  # is deleted
  #
  def after_destroy(collection)
    DistributionManager.delete_story(
        collection.ticker_action,
        collection.user.access_token) if collection.ticker_action
  end
end
