# Observe events on various models to keep the Product Cache
# stores persistent
#
class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  # Product is created
  #
  def after_create(product)
    expire_user_top_stores(product.user_id)
  end

  # Before a product is updated
  #
  def before_update(product)
    if product.store_id_changed?
      expire_user_top_stores(product.user_id)
    end

    if product.user_id_changed?
      expire_user_top_stores(product.user_id)
      expire_user_top_stores(product.user_id_was)
    end
  end

  # Product is updated
  #
  def after_update(product)
  end

  # Product is destroyed
  #
  def after_destroy(product)
    expire_user_top_stores(product.user_id)
  end

  # Expire the top stores for a user
  #
  def expire_user_top_stores(user_id)
    expire_cache KEYS[:user_top_stores] % user_id
  end
end
