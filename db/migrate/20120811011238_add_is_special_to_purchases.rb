class AddIsSpecialToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :is_special, :boolean, :default => false
    add_index :purchases, :is_special
  end

  def self.down
    remove_column :purchases, :is_special
  end
end
