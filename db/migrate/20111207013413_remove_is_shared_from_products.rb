class RemoveIsSharedFromProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :is_shared
  end

  def self.down
    add_column :products, :is_shared, :boolean, :default => false
  end
end
