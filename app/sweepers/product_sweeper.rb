# Oberve events on Product models to keep various cache
# stores persistent 
#
class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  # Product is created
  #
  def after_create(product)
    expire_user_top_stores(product.user_id)

    expire_user_product_suggestions(product.user_id)

    expire_user_products(product.user_id)
    expire_store_products(product.store_id)
  end

  # Before a product is updated
  #
  def before_update(product)

    if product.store_id_changed?
      expire_user_top_stores(product.user_id)

      expire_store_products(product.store_id)
      expire_store_products(product.store_id_was)
    end

    if product.user_id_changed?
      expire_user_top_stores(product.user_id)
      expire_user_top_stores(product.user_id_was)

      expire_user_products(product.user_id)
      expire_user_products(product.user_id_was)
    end

    if product.suggestion_id_changed?
      expire_user_product_suggestions(product.user_id)
    end

    expire_user_products(product.user_id)
    expire_store_products(product.store_id)
  end

  # Product is updated
  #
  def after_update(product)
  end

  # Product is destroyed
  #
  def after_destroy(product)
    expire_user_top_stores(product.user_id)

    expire_user_products(product.user_id)
    expire_store_products(product.store_id)

    expire_user_product_suggestions(product.user_id)
  end

  # Expire the top stores for a user
  #
  def expire_user_top_stores(user_id)
    expire_cache KEYS[:user_top_stores] % user_id
  end

  # Expire cache fragment for a user's products 
  #
  def expire_user_products(user_id)
    expire_cache KEYS[:user_products] % user_id
  end

  # Expire cache fragment for user's product suggestions
  #
  def expire_user_product_suggestions(user_id)
    expire_cache KEYS[:user_product_suggestions] % 
                  [user_id,Configuration.read(
                            ConfigurationVariable::SuggestionCacheKey)]
  end

  # Expire cache fragment for a store's products 
  #
  def expire_store_products(store_id)
    expire_cache KEYS[:store_products] % store_id
  end
end

