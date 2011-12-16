class ReplaceTypeByForInAchievementsSet < ActiveRecord::Migration
  def self.up
    remove_index  :achievement_sets, [:type,:owner_id]
    remove_column :achievement_sets, :type

    add_column    :achievement_sets, :for, :string 
    add_index     :achievement_sets, [:for,:owner_id]
  end

  def self.down
    remove_index  :achievement_sets, [:for,:owner_id]
    remove_column :achievement_sets, :for

    add_column    :achievement_sets, :type, :string
    add_index     :achievement_sets, [:type,:owner_id]
  end
end
