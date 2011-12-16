class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.integer :achievable_id
      t.string  :achievable_type
      t.integer :user_id
      t.integer :achievement_set_id

      t.timestamps
    end

    add_index :achievements,  :user_id
    add_index :achievements,  :achievement_set_id
  end

  def self.down
    drop_table :achievements
  end
end
