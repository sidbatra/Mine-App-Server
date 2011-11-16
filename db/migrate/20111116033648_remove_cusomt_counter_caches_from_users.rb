class RemoveCusomtCounterCachesFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :products_price
    remove_column :users, :products_1_count
    remove_column :users, :products_2_count
    remove_column :users, :products_3_count
    remove_column :users, :products_4_count
    remove_column :users, :products_5_count
    remove_column :users, :products_6_count
    remove_column :users, :products_7_count
    remove_column :users, :products_8_count
  end

  def self.down
  end
end
