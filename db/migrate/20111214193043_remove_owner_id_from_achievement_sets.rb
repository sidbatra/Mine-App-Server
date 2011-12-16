class RemoveOwnerIdFromAchievementSets < ActiveRecord::Migration
  def self.up
    remove_index :achievement_sets, :owner_id
  end

  def self.down
  end
end
