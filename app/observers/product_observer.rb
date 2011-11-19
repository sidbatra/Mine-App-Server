# Observe events on the Product model
#
class ProductObserver < ActiveRecord::Observer

  # Alert notification manager about a new product
  # Delete affected cache values
  #
  def after_create(product)
    Cache.delete(KEYS[:user_category_count] % [product.user_id,product.category_id])
    Cache.delete(KEYS[:user_price] % product.user_id)

    Cache.delete(KEYS[:store_category_count] % [product.store_id,product.category_id])
    Cache.delete(KEYS[:store_price] % product.store_id)

    ProcessingQueue.push(
      NotificationManager,
      :new_product,
      product.id)
  end

  # Test modifications to particular columns that require changes in
  # states of other tables or post processing on the current table
  #
  def before_update(product)

    if product.orig_image_url_changed?
      product.rehost    = true
      product.is_hosted = false
    end

    if product.price_changed?
      Cache.delete(KEYS[:user_price] % product.user_id)
      Cache.delete(KEYS[:store_price] % product.store_id)
    end

    if product.store_id_changed? 
      Store.increment_counter(:products_count,product.store_id)
      Store.decrement_counter(:products_count,product.store_id_was)

      Cache.delete(KEYS[:store_price] % product.store_id)
      Cache.delete(KEYS[:store_price] % product.store_id_was)

      Cache.delete(KEYS[:store_category_count] % [product.store_id_was,product.category_id])
      Cache.delete(KEYS[:store_category_count] % [product.store_id,product.category_id])
    end
  end

  # Post process based on the flags set in before_update
  #
  def after_update(product)
    ProcessingQueue.push(
      NotificationManager,
      :update_product,
      product.id) if product.rehost
  end

  # Delete affected cache values
  #
  def after_destroy(product)
    Cache.delete(KEYS[:user_category_count] % [product.user_id,product.category_id])
    Cache.delete(KEYS[:user_price] % product.user_id)

    Cache.delete(KEYS[:store_category_count] % [product.store_id,product.category_id])
    Cache.delete(KEYS[:store_price] % product.store_id)
  end

end
