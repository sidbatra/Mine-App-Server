# Observe events on AchievementSet models to keep various cache
# achivement sets persistent 
#
class AchievementSetSweeper < ActionController::Caching::Sweeper
  observe AchievementSet, Achievement

  # AchievementSet or Achievement is created
  #
  def after_create(entity)
    expire_relevant_cache(entity) if entity.is_a?(AchievementSet)
  end

  # AchievementSet or Achievement is updated
  #
  def after_update(entity)
  end

  # AchievementSet or Achievement is deleted
  #
  def after_destroy(entity)
    set = entity.is_a?(AchievementSet) ? entity : entity.achievement_set
    expire_relevant_cache(set) unless set.expired?
  end


  # Expire cache based on the type of the achievement set 
  #
  def expire_relevant_cache(achievement_set)

    case achievement_set.for
    when AchievementSetFor::StarUsers
      expire_star_users
    when AchievementSetFor::TopShoppers
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
