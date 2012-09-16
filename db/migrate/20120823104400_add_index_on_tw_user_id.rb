class AddIndexOnTwUserId < ActiveRecord::Migration
  def self.up
    add_index :users, :tw_user_id, :unique => true
  end

  def self.down
    remove_index :users, :tw_user_id
  end
end
