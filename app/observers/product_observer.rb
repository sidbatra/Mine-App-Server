# Observe events on the Product model
#
class ProductObserver < ActiveRecord::Observer

  # Alert notification manager about a new product
  # Update custom counter cache values
  #
  def after_create(product)
    user = product.user
    user.add_product_worth(product.price,product.category_id)

    ProcessingQueue.push(
      NotificationManager,
      :new_product,
      product.id)
  end

  # Update custom counter cache values
  #
  def after_destroy(product)
    user = product.user
    user.remove_product_worth(product.price,product.category_id)
  end

end
