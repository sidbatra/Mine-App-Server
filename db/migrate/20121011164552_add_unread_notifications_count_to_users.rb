class AddUnreadNotificationsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_notifications_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :unread_notifications_count
  end
end
