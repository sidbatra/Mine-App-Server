class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.string :entity
      t.string :event
      t.integer :resource_id
      t.string :resource_type
      t.string :image_url
      t.integer :identifier
      t.string :details
      t.boolean :unread, :default => true

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, :identifier
    add_index :notifications, :created_at
    add_index :notifications, [:resource_id,:resource_type]
  end

  def self.down
    drop_table :notifications
  end
end
