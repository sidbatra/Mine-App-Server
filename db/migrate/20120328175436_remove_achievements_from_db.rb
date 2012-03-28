class RemoveAchievementsFromDb < ActiveRecord::Migration
  def self.up
    drop_table :achievements
  end

  def self.down
  end
end
