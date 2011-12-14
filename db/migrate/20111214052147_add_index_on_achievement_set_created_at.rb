class AddIndexOnAchievementSetCreatedAt < ActiveRecord::Migration
  def self.up
    add_index :achievement_sets, :created_at
  end

  def self.down
    remove_index :achievement_sets, :created_at
  end
end
