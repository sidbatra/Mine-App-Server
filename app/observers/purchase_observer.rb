class PurchaseObserver < ActiveRecord::Observer

  # Update shoppings for the purchase creator and
  # hand off the rest to the purchase delayed observer.
  #
  def after_create(purchase)
    if purchase.store_id
      shopping = Shopping.add(
                  purchase.user_id,
                  purchase.store_id,
                  ShoppingSource::Purchase)

      shopping.increment_purchases_count
    end

    ProcessingQueue.push(
      PurchaseDelayedObserver,
      :after_create,
      purchase.id)
  end

  # Update shoppings for the purchase creator if store_id has been
  # modified.
  # Mark the purchase for re-hosting if original url has changed.
  #
  def before_update(purchase)

    purchase.block_delayed_update = purchase.changed.length == 1 && 
                                      purchase.updated_at_changed?

    if purchase.orig_image_url_changed?
      purchase.rehost = true
      purchase.is_processed = false
    end

    if purchase.store_id_changed? 
      if purchase.store_id
        Store.increment_counter(:purchases_count,purchase.store_id) 

        shopping = Shopping.add(
                    purchase.user_id,
                    purchase.store_id,
                    ShoppingSource::Purchase)
        shopping.increment_purchases_count
      end

      if purchase.store_id_was
        Store.decrement_counter(:purchases_count,purchase.store_id_was) 

        shopping = Shopping.add(
                    purchase.user_id,
                    purchase.store_id_was,
                    ShoppingSource::Purchase)
        shopping.decrement_purchases_count
      end
    end
  end

  # Hand off to purchase delayed observer with conditional
  # rehosting.
  #
  def after_update(purchase)
    ProcessingQueue.push(
      PurchaseDelayedObserver,
      :after_update,
      purchase.id,
      {:rehost => purchase.rehost}) unless purchase.block_delayed_update
  end

  # Update shoppings for the purchase creator.
  #
  def after_destroy(purchase)
    if purchase.store_id
      shopping = Shopping.add(
                  purchase.user_id,
                  purchase.store_id,
                  ShoppingSource::Purchase)
      shopping.decrement_purchases_count
    end

    if purchase.fb_action_id && 
        purchase.fb_action_id != FBSharing::Underway

      ProcessingQueue.push(
        DistributionManager,
        :delete_story,
        purchase.fb_action_id,
        purchase.user.access_token)
    end
  end

end
