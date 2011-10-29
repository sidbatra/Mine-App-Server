class AddProductCategoryCounterCachesToUser < ActiveRecord::Migration
  def self.up
    (1..8).each do |i|
      add_column :users, "products_#{i}_count", :integer, :default => 0
    end
  end

  def self.down
    (1..8).each do |i|
      remove_column :users, "products_#{i}_count"
    end
  end
end
