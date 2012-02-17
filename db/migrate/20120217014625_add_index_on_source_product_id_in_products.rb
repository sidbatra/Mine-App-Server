class AddIndexOnSourceProductIdInProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :source_product_id
  end

  def self.down
    remove_index :products, :source_product_id
  end
end
