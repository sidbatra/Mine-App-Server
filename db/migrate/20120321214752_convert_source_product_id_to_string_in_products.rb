class ConvertSourceProductIdToStringInProducts < ActiveRecord::Migration
  def self.up
    change_column :products, :source_product_id, :string
    remove_index :products,:title
  end

  def self.down
    change_column :products, :source_product_id, :integer
    add_index :products,:title
  end
end
