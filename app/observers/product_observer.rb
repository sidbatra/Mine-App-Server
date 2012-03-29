# Observe events on the Product model
#
class ProductObserver < ActiveRecord::Observer

  # Alert notification manager about a new product
  # Delete affected cache values
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

    if product.user_id_changed? 
      User.increment_counter(:products_count,product.user_id)
      User.decrement_counter(:products_count,product.user_id_was)
    end
  end

  # Post process based on the flags set in before_update
  #
  def after_update(product)
    ProcessingQueue.push(
      ProductDelayedObserver,
      :after_update,
      product.id,
      {:rehost => product.rehost})
  end

  # Delete affected cache values
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
