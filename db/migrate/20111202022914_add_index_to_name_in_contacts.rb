class AddIndexToNameInContacts < ActiveRecord::Migration
  def self.up
    add_index :contacts, :name
  end

  def self.down
    remove_index :contacts, :name
  end
end
