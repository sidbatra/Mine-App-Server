class AddStoreIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :store_id, :integer
    add_column :products, :price, :float
  end

  def self.down
    remove_column :products, :store_id
    remove_column :products, :price
  end
end
