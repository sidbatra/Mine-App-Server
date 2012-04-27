class RemoveAchievementSetsFromDb < ActiveRecord::Migration
  def self.up
    drop_table :achievement_sets
  end

  def self.down
  end
end
