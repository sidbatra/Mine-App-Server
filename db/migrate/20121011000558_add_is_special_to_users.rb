class AddIsSpecialToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_special, :boolean, :default => false
    add_index :users, :is_special
  end

  def self.down
    remove_column :users, :is_special
  end
end
