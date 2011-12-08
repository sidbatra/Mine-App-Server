# Observe events on various models to keep the Product Cache
# stores persistent
#
class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  # Product is created
  #
  def after_create(product)
    expire_user_category_count(product.user_id,product.category_id)
    expire_user_price(product.user_id)

    expire_store_category_count(product.store_id,product.category_id)
    expire_store_price(product.store_id)

    expire_user_top_stores(product.user_id)
    expire_store_top_products(product.store_id)
  end

  # Before a product is updated
  #
  def before_update(product)

    if product.price_changed?
      expire_user_price(product.user_id)
      expire_store_price(product.store_id)
    end

    if product.store_id_changed?
      expire_user_top_stores(product.user_id)

      expire_store_category_count(product.store_id,product.category_id)
      expire_store_category_count(product.store_id_was,product.category_id_was)

      expire_store_price(product.store_id)
      expire_store_price(product.store_id_was)

      expire_store_top_products(product.store_id)
      expire_store_top_products(product.store_id_was)
    end

    if product.user_id_changed?
      expire_user_category_count(product.user_id,product.category_id)
      expire_user_category_count(product.user_id_was,product.category_id_was)

      expire_user_price(product.user_id)
      expire_user_price(product.user_id_was)

      expire_user_top_stores(product.user_id)
      expire_user_top_stores(product.user_id_was)
    end

    if product.category_id_changed?
      expire_user_category_count(product.user_id,product.category_id)
      expire_user_category_count(product.user_id,product.category_id_was)

      expire_store_category_count(product.store_id,product.category_id)
      expire_store_category_count(product.store_id,product.category_id_was)
    end
  end

  # Product is updated
  #
  def after_update(product)
  end

  # Product is destroyed
  #
  def after_destroy(product)
    expire_user_category_count(product.user_id,product.category_id)
    expire_user_price(product.user_id)

    expire_store_category_count(product.store_id,product.category_id)
    expire_store_price(product.store_id)

    expire_user_top_stores(product.user_id)
    expire_store_top_products(product.store_id)
  end

  # Expire the top stores for a user
  #
  def expire_user_top_stores(user_id)
    expire_cache KEYS[:user_top_stores] % user_id
  end

  # Expire category count cache for a user's product category
  #
  def expire_user_category_count(user_id,category_id)
    Cache.delete(KEYS[:user_category_count] % [user_id,category_id])
  end

  # Expire price of all products for a user
  #
  def expire_user_price(user_id)
    Cache.delete(KEYS[:user_price] % user_id)
  end

  # Expire category count cache for a store's product category
  #
  def expire_store_category_count(store_id,category_id)
    Cache.delete(KEYS[:store_category_count] % [store_id,category_id])
  end

  # Expire price of all products for a store
  #
  def expire_store_price(store_id)
    Cache.delete(KEYS[:store_price] % store_id)
  end

  # Expire top products at the given store
  #
  def expire_store_top_products(store_id)
    expire_cache KEYS[:store_top_products] % store_id
  end
end

