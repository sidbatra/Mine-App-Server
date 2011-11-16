class AddIsActiveToFollowings < ActiveRecord::Migration
  def self.up
    add_column :followings, :is_active, :boolean, :default => true
    add_index :followings, :is_active
  end

  def self.down
    remove_column :followings, :is_active
  end
end
