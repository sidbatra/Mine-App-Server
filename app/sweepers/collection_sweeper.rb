# Observer events on Collection models to keep various
# cache stores persistent
#
class CollectionSweeper < ActionController::Caching::Sweeper 
  observe Collection

  # Collection is created
  #
  def after_create(collection)
    expire_user_collections(collection)
  end

  # Collection is updated
  #
  def after_update(collection)
    expire_user_collections(collection)
  end

  # Collection is destroyed
  #
  def after_destroy(collection)
    expire_user_collections(collection)
  end

  # Expire cache fragment for a user's collections
  #
  def expire_user_collections(collection)
    expire_cache KEYS[:user_collections] % collection.user_id
  end

end
