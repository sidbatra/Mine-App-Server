class AddIndexOnActionableIdAndTypeInAchievements < ActiveRecord::Migration
  def self.up
    add_index :achievements, [:achievable_id,:achievable_type]
  end

  def self.down
    remove_index :achievements, [:achievable_id,:achievable_type]
  end
end
