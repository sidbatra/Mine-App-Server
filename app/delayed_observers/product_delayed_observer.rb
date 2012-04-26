class ProductDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(product_id)
    product = Product.find(product_id)
    product.host
  end

end
