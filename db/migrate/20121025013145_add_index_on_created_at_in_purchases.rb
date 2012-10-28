class AddIndexOnCreatedAtInPurchases < ActiveRecord::Migration
  def self.up
    add_index :purchases, :created_at
  end

  def self.down
    remove_index :purchases, :created_at
  end
end
