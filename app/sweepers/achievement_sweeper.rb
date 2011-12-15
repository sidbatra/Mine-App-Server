# Observe events on Achievement models to keep various cache
# achivement persistent 
#
class AchievementSweeper < ActionController::Caching::Sweeper
  observe Achievement 

  # Achievement is created
  #
  def after_create(achievement)
  end

  # Achievement is updated
  #
  def after_update(achievement)
  end

  # Achievement is deleted
  #
  def after_destroy(achievement)
    achievement_set = achievement.achievement_set
    expire_relevant_cache(achievement_set) unless achievement_set.expired?
  end


  # Expire cache based on the type of the achievement set 
  #
  def expire_relevant_cache(achievement_set)

    if achievement_set.for_star_users?
      expire_star_users
    elsif achievement_set.for_top_shoppers?
      expire_top_shoppers(achievement_set.owner_id)
    end
  end

  # Expire cache fragment for star users
  #
  def expire_star_users
    expire_cache KEYS[:star_users]
  end

  # Expire cache fragment for top shoppers 
  #
  def expire_top_shoppers(store_id)
    expire_cache KEYS[:store_top_shoppers] % store_id 
  end

end
