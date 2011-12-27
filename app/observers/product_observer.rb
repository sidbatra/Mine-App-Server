# Observe events on the Product model
#
class ProductObserver < ActiveRecord::Observer

  # Alert notification manager about a new product
  # Delete affected cache values
  #
  def after_create(product)

    if product.store_id
      Shopping.add(product.user_id,product.store_id,ShoppingSource::Product)
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
        Shopping.add(product.user_id,product.store_id,ShoppingSource::Product)
      end

      if product.store_id_was
        Store.decrement_counter(:products_count,product.store_id_was) 
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
      NotificationManager,
      :update_product,
      product.id) if product.rehost
  end

  # Delete affected cache values
  #
  def after_destroy(product)
    action = Action.fetch_own_on_for_user(
                        product.class.name,
                        product.source_product_id,
                        product.user_id)
    action.destroy if action
  end

end
