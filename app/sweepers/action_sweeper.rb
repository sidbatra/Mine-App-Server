# Observer events on the Action model to keep 
# action related cache stores persistent
#
class ActionSweeper < ActionController::Caching::Sweeper
  observe Action

  # Fired when a action is created
  #
  def after_create(action)
    expire_actions(action)
    expire_actioned_products(action)
  end

  # Fired when a action is updated
  #
  def after_update(action)
    expire_actions(action)
    expire_actioned_products(action)
  end

  # Fired when a action is destroyed
  #
  def after_destroy(action)
    expire_actions(action)
    expire_actioned_products(action)
  end

  # Expire actions for the associated actionable
  #
  def expire_actions(action)
    expire_cache(KEYS[:action_actionable] % 
        [action.actionable_id,action.actionable_type])
  end

  # Expire set of products under the same action by the same user
  #
  def expire_actioned_products(action)
    if action.actionable_type == Product.name && 
            action.name != ActionName::Own
      key = "user_#{action.name}_products_in_category".to_sym

      expire_cache(KEYS[key] % [action.user_id,action.actionable.category_id])
      expire_cache(KEYS[key] % [action.user_id,0])
    end
  end
end
