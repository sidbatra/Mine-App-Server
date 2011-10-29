class AddFollowingAndFollowersCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :followings_count, :integer, :default => 0
    add_column :users, :inverse_followings_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :followings_count
    remove_column :users, :inverse_followings_count
  end
end
