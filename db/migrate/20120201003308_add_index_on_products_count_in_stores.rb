class AddIndexOnProductsCountInStores < ActiveRecord::Migration
  def self.up
    add_index :stores, :products_count
  end

  def self.down
    remove_index :stores, :products_count
  end
end
