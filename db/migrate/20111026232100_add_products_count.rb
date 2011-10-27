class AddProductsCount < ActiveRecord::Migration
  def self.up
    add_column :users, :products_count, :integer, :default => 0

    User.all.each do |u|
      u.update_attribute :products_count, u.products.length
    end
  end

  def self.down
    remove_column :users, :products_count
  end
end
