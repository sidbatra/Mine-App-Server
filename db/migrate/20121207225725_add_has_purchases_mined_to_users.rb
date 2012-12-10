class AddHasPurchasesMinedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :has_purchases_mined, :boolean, :default => false
  end

  def self.down
    remove_column :users, :has_purchases_mined
  end
end
