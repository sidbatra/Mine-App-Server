class CreateAchievementSets < ActiveRecord::Migration
  def self.up
    create_table :achievement_sets do |t|
      t.integer   :owner_id
      t.string    :type
      t.datetime  :expired_at

      t.timestamps
    end

    add_index :achievement_sets,  :owner_id
    add_index :achievement_sets,  :type
  end

  def self.down
    drop_table :achievement_sets
  end
end
