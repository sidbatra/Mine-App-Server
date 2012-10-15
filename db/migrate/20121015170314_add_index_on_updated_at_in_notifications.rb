class AddIndexOnUpdatedAtInNotifications < ActiveRecord::Migration
  def self.up
    add_index :notifications, :updated_at
    remove_index :notifications, :created_at
  end

  def self.down
    remove_index :notifications, :updated_at
    add_index :notifications, :created_at
  end
end
