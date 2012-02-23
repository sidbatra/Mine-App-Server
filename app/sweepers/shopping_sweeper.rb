# Observe events on the Shopping model to keep 
# shopping related cache stores persistent
#
class ShoppingSweeper < ActionController::Caching::Sweeper
  observe Shopping

  # Fired when a shopping is created
  #
  def after_create(shopping)
    expire_user_top_stores(shopping.user_id)
  end

  # Fired when a shopping is destroyed
  #
  def after_destroy(shopping)
    expire_user_top_stores(shopping.user_id)
  end

  # Expire the top stores for a user
  #
  def expire_user_top_stores(user_id)
    expire_cache KEYS[:user_top_stores] % user_id
  end
end
