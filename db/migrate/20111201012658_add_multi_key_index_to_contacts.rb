class AddMultiKeyIndexToContacts < ActiveRecord::Migration
  def self.up
    remove_index :contacts, :user_id
    add_index :contacts, [:user_id,:third_party_id], :unique => true
  end

  def self.down
    remove_index :contacts, [:user_id,:third_party_id]
  end
end
