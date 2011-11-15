class AddIndexOnStoreIdInProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :store_id
  end

  def self.down
    remove_index :products, :store_id
  end
end
