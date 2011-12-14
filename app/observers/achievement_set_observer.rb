# Observe events on the AchievementSet model
#
class AchievementSetObserver < ActiveRecord::Observer

  # Once an achievement set is added, expire the 
  # previous achievement set of the same type and
  # owner id
  #
  def after_create(achievement_set)
    previous = achievement_set.previous
    previous.expire if previous
  end

end
