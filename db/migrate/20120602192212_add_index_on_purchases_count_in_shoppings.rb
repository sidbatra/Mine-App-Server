class AddIndexOnPurchasesCountInShoppings < ActiveRecord::Migration
  def self.up
    add_index :shoppings, :purchases_count
  end

  def self.down
    remove_index :shoppings, :purchases_count
  end
end
