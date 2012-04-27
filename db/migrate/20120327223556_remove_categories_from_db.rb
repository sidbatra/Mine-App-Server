class RemoveCategoriesFromDb < ActiveRecord::Migration
  def self.up
    remove_column :products, :category_id
    drop_table :categories
  end

  def self.down
  end
end
