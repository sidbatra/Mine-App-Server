class AddFirstAndLastNameToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :first_name, :string
    add_column :contacts, :last_name, :string
  end

  def self.down
    remove_column :contacts, :first_name
    remove_column :contacts, :last_name
  end
end
