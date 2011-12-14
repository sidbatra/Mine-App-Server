# Observe events on the AchievementSet model
#
class AchievementSetObserver < ActiveRecord::Observer

  # Once an achievement set is added, expire the 
  # previous achievement set of the same type and
  # owner id
  #
  def after_create(achievement_set)
    achievement_sets = AchievementSet.find_all_by_for_and_owner_id(
                                                      achievement_set.for,
                                                      achievement_set.owner_id)

    achievement_sets[-2].expire if achievement_sets.length > 1
  end

end
