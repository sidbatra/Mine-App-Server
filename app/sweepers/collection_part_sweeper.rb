# Observer events on CollectionPart models to keep various
# cache stores persistent
#
class CollectionPartSweeper < ActionController::Caching::Sweeper 
  observe CollectionPart

  # Collection part is updated
  #
  def after_update(collection_part)
    if collection_part.collection_id_changed?
      expire_collection_products(collection_part.collection_id)
      expire_collection_products(collection_part.collection_id_was)
    end

    expire_collection_products(collection_part.collection_id)
    expire_user_collections(collection_part)
  end

  # Collection part is destroyed
  #
  def after_destroy(collection_part)
    expire_collection_products(collection_part.collection_id)
    expire_user_collections(collection_part)
  end

  # Expire cache fragment for collection products
  #
  def expire_collection_products(collection_id)
    expire_cache KEYS[:collection_products] % collection_id
  end

  # Expire cache fragment for a user's collections
  #
  def expire_user_collections(collection_part)
    expire_cache KEYS[:user_collections] % collection_part.collection.user_id
  end
end
