class AddIsSharedToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :is_shared, :boolean, :default => false
  end

  def self.down
    remove_column :products, :is_shared
  end
end
