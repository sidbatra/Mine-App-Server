class AddProductsPriceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :products_price, :float, :default => 0
  end

  def self.down
    remove_column :users, :products_price
  end
end
