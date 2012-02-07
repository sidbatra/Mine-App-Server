class AddIndexOnFollowingCreatedAt < ActiveRecord::Migration
  def self.up
    add_index :followings, :created_at
  end

  def self.down
    remove_index :followings, :created_at
  end
end
