class AddWeightToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :weight, :integer, :default => 0

    Category.all.each do |category|
      category.weight = 10 - category.id
      category.save!
    end

    add_index :categories, :weight
  end

  def self.down
    remove_column :categories, :weight
  end
end
