class ProductObserver < ActiveRecord::Observer

  # Update shoppings for the product creator and
  # hand off the rest to the product delayed observer.
  #
  def after_create(product)
    if product.store_id
      shopping = Shopping.add(
                  product.user_id,
                  product.store_id,
                  ShoppingSource::Product)

      shopping.increment_products_count
    end

    ProcessingQueue.push(
      ProductDelayedObserver,
      :after_create,
      product.id)
  end

  # Update shoppings for the product creator if store_id has been
  # modified.
  # Mark the product for re-hosting if original url has changed.
  #
  def before_update(product)

    if product.orig_image_url_changed?
      product.rehost = true
      product.is_processed = false
    end

    if product.store_id_changed? 
      if product.store_id
        Store.increment_counter(:products_count,product.store_id) 

        shopping = Shopping.add(
                    product.user_id,
                    product.store_id,
                    ShoppingSource::Product)
        shopping.increment_products_count
      end

      if product.store_id_was
        Store.decrement_counter(:products_count,product.store_id_was) 

        shopping = Shopping.add(
                    product.user_id,
                    product.store_id_was,
                    ShoppingSource::Product)
        shopping.decrement_products_count
      end
    end
  end

  # Hand off to product delayed observer with conditional
  # rehosting.
  #
  def after_update(product)
    ProcessingQueue.push(
      ProductDelayedObserver,
      :after_update,
      product.id,
      {:rehost => product.rehost})
  end

  # Update shoppings for the product creator.
  #
  def after_destroy(product)
    if product.store_id
      shopping = Shopping.add(
                  product.user_id,
                  product.store_id,
                  ShoppingSource::Product)
      shopping.decrement_products_count
    end
  end

end
