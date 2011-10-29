class AddIndexOnProductCategories < ActiveRecord::Migration
  def self.up
    add_index :products, :category
  end

  def self.down
    remove_index :products, :category
  end
end
