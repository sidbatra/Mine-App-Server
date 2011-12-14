# Observe events on AchievementSet models to keep various cache
# achivement sets persistent 
#
class AchievementSetSweeper < ActionController::Caching::Sweeper
  observe AchievementSet 

  # AchievementSet is created
  #
  def after_create(achievement_set)
    if achievement_set.for == 'star_users'
      expire_top_users
    end
  end

  # AchievementSet is updated
  #
  def after_update(achievement_set)
  end

  # AchievementSet is deleted
  #
  def after_destroy(achievement_set)
    if achievement_set.for == 'star_users'
      expire_top_users
    end
  end

  # Expire cache fragment for top users
  #
  def expire_top_users
    expire_cache KEYS[:star_users]
  end

end
