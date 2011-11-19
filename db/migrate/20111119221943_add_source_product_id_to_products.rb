class AddSourceProductIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :source_product_id, :integer
  end

  def self.down
    remove_column :products, :source_product_id
  end
end
