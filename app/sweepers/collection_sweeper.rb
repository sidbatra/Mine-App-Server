# Observer events on Collection models to keep various
# cache stores persistent
#
class CollectionSweeper < ActionController::Caching::Sweeper 
  observe Collection

  # Collection is created
  #
  def after_create(collection)
    expire_user_collections(collection)
    expire_user_top_products(collection.user_id)
  end

  # Collection is updated
  #
  def after_update(collection)
    expire_user_collections(collection)
    expire_user_top_products(collection.user_id)
  end

  # Collection is destroyed
  #
  def after_destroy(collection)
    expire_user_collections(collection)
    expire_user_top_products(collection.user_id)
  end

  # Expire cache fragment for a user's collections
  #
  def expire_user_collections(collection)
    expire_cache KEYS[:user_collections] % collection.user_id
  end

  # Expire the top products for a user
  #
  def expire_user_top_products(user_id)
    expire_cache KEYS[:user_top_products] % user_id
  end

end
