class AddCommentsCountToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :comments_count, :integer, :default => 0

    Product.all.each do |p| 
      Product.update_counters p.id, :comments_count => p.comments.length
    end
  end

  def self.down
    remove_column :products, :comments_count
  end
end
