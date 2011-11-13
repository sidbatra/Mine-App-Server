class CleanUpCategoryInProducts < ActiveRecord::Migration
  def self.up
    remove_column :products,:category
    add_index :products, :category_id
  end

  def self.down
  end
end
