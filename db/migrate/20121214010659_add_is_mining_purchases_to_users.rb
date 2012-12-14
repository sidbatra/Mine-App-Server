class AddIsMiningPurchasesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_mining_purchases, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_mining_purchases
  end
end
