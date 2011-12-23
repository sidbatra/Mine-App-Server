class EditIndexInShoppings < ActiveRecord::Migration
  def self.up
    remove_index :shoppings, :user_id
    add_index :shoppings, [:user_id,:store_id], :unique => true
  end

  def self.down
    remove_index :shoppings, [:user_id,:store_id] 
    add_index :shoppings, :user_id
  end
end
