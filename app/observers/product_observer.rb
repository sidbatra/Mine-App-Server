# Observe events on the Product model
#
class ProductObserver < ActiveRecord::Observer

  # Alert notification manager about a new product
  # Delete affected cache values
  #
  def after_create(product)
    Cache.delete(KEYS[:user_category_count] % [product.user_id,product.category_id])
    Cache.delete(KEYS[:user_price] % product.user_id)

    ProcessingQueue.push(
      NotificationManager,
      :new_product,
      product.id)
  end

  # Delete affected cache values
  #
  def after_destroy(product)
    Cache.delete(KEYS[:user_category_count] % [product.user_id,product.category_id])
    Cache.delete(KEYS[:user_price] % product.user_id)
  end

end
