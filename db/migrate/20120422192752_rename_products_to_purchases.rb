class RenameProductsToPurchases < ActiveRecord::Migration
  def self.up
    indexes = ActiveRecord::Base.connection.indexes('products')
    indexes = indexes.map{|d| d.columns.first.to_sym}

    indexes.each do |index| 
      remove_index :products, index
    end

    rename_table :products, :purchases

    indexes.each do |index| 
      add_index :purchases, index
    end

    rename_column :shoppings, :products_count, :purchases_count

    remove_index :stores, :products_count
    rename_column :stores, :products_count, :purchases_count
    add_index :stores, :purchases_count

    remove_index :users, :products_count
    rename_column :users, :products_count, :purchases_count
    add_index :users, :purchases_count
  end

  def self.down
    indexes = ActiveRecord::Base.connection.indexes('purchases')
    indexes = indexes.map{|d| d.columns.first.to_sym}

    indexes.each do |index| 
      remove_index :purchases, index
    end

    rename_table :purchases, :products

    indexes.each do |index| 
      add_index :products, index
    end

    rename_column :shoppings, :purchases_count, :products_count

    remove_index :stores, :purchases_count
    rename_column :stores, :purchases_count, :products_count
    add_index :stores, :products_count

    remove_index :users, :purchases_count
    rename_column :users, :purchases_count, :products_count
    add_index :users, :products_count
  end
end
