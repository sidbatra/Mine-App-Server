# Oberve events on Product models to keep various cache
# stores persistent 
#
class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  # Product is created
  #
  def after_create(product)
    expire_user_category_count(product.user_id,product.category_id)

    expire_store_category_count(product.store_id,product.category_id)

    expire_user_top_stores(product.user_id)
    expire_store_top_products(product.store_id)

    expire_user_product_suggestions(product.user_id)

    expire_user_products_in_category(product.user_id,product.category_id)
    expire_store_products_in_category(product.store_id,product.category_id)
  end

  # Before a product is updated
  #
  def before_update(product)

    if product.store_id_changed?
      expire_user_top_stores(product.user_id)

      expire_store_category_count(product.store_id,product.category_id)
      expire_store_category_count(product.store_id_was,product.category_id_was)

      expire_store_top_products(product.store_id)
      expire_store_top_products(product.store_id_was)
    
      expire_store_products_in_category(product.store_id,product.category_id)
      expire_store_products_in_category(product.store_id_was,product.category_id_was)
    end

    if product.user_id_changed?
      expire_user_category_count(product.user_id,product.category_id)
      expire_user_category_count(product.user_id_was,product.category_id_was)

      expire_user_top_stores(product.user_id)
      expire_user_top_stores(product.user_id_was)

      expire_user_top_products(product.user_id)
      expire_user_top_products(product.user_id_was)

      expire_user_products_in_category(product.user_id,product.category_id)
      expire_user_products_in_category(product.user_id_was,product.category_id_was)
    end

    if product.category_id_changed?
      expire_user_category_count(product.user_id,product.category_id)
      expire_user_category_count(product.user_id,product.category_id_was)

      expire_store_category_count(product.store_id,product.category_id)
      expire_store_category_count(product.store_id,product.category_id_was)

      expire_user_products_in_category(product.user_id,product.category_id)
      expire_user_products_in_category(product.user_id,product.category_id_was)

      expire_store_products_in_category(product.store_id,product.category_id)
      expire_store_products_in_category(product.store_id,product.category_id_was)
    end

    if product.suggestion_id_changed?
      expire_user_product_suggestions(product.user_id)
    end

    expire_user_top_products(product.user_id)
    expire_store_top_products(product.store_id)
    expire_user_products_in_category(product.user_id,product.category_id)
    expire_store_products_in_category(product.store_id,product.category_id)
  end

  # Product is updated
  #
  def after_update(product)
  end

  # Product is destroyed
  #
  def after_destroy(product)
    expire_user_category_count(product.user_id,product.category_id)

    expire_store_category_count(product.store_id,product.category_id)

    expire_user_top_stores(product.user_id)
    expire_user_top_products(product.user_id)
    expire_store_top_products(product.store_id)

    expire_user_products_in_category(product.user_id,product.category_id)
    expire_store_products_in_category(product.store_id,product.category_id)

    expire_user_product_suggestions(product.user_id)
  end


  # Expire category count cache for a user's product category
  #
  def expire_user_category_count(user_id,category_id)
    Cache.delete(KEYS[:user_category_count] % [user_id,category_id])
  end

  # Expire the top stores for a user
  #
  def expire_user_top_stores(user_id)
    expire_cache KEYS[:user_top_stores] % user_id
  end

  # Expire the top products for a user
  #
  def expire_user_top_products(user_id)
    expire_cache KEYS[:user_top_products] % user_id
  end

  # Expire cache fragment for user's products in a category
  #
  def expire_user_products_in_category(user_id,category_id)
    expire_cache KEYS[:user_products_in_category] % [user_id,category_id]
    expire_cache KEYS[:user_products_in_category] % [user_id,0]
  end

  # Expire cache fragment for user's product suggestions
  #
  def expire_user_product_suggestions(user_id)
    expire_cache KEYS[:user_product_suggestions] % 
                  [user_id,Configuration.read(
                            ConfigurationVariable::SuggestionCacheKey)]
  end

  # Expire category count cache for a store's product category
  #
  def expire_store_category_count(store_id,category_id)
    Cache.delete(KEYS[:store_category_count] % [store_id,category_id])
  end

  # Expire top products at the given store
  #
  def expire_store_top_products(store_id)
    expire_cache KEYS[:store_top_products] % store_id
  end

  # Expire cache fragment for store's products in a category
  #
  def expire_store_products_in_category(store_id,category_id)
    expire_cache KEYS[:store_products_in_category] % [store_id,category_id]
    expire_cache KEYS[:store_products_in_category] % [store_id,0]
  end
end

