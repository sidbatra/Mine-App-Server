class AddIsHiddenToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :is_hidden, :boolean, :default => false
    add_index :purchases, :is_hidden
  end

  def self.down
    remove_column :purchases, :is_hidden
  end
end
