# Observe events on the Product model
#
class ProductObserver < ActiveRecord::Observer

  # Alert notification manager about a new product
  #
  def after_create(product)
    #ProcessingQueue.push(
    #  NotificationManager,
    #  :new_product,
    #  product.id)
  end

end
