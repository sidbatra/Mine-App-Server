# Observer events on the Action model to keep 
# action related cache stores persistent
#
class ActionSweeper < ActionController::Caching::Sweeper
  observe Action

  # Fired when a action is created
  #
  def after_create(action)
    expire_actions(action)
  end

  # Fired when a action is updated
  #
  def after_update(action)
    expire_actions(action)
  end

  # Fired when a action is destroyed
  #
  def after_destroy(action)
    expire_actions(action)
  end

  # Expire actions for the associated actionable
  #
  def expire_actions(action)
    expire_cache(KEYS[:action_actionable] % 
        [action.actionable_id,action.actionable_type])
  end

end
