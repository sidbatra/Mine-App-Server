class ProductObserver < ActiveRecord::Observer

  # Call the product delayed observer to handle
  # image hosting
  #
  def after_create(product)
    ProcessingQueue.push(
      ProductDelayedObserver,
      :after_create,
      product.id)
  end

end
