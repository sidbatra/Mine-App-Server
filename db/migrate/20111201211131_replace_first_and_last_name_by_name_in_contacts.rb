class ReplaceFirstAndLastNameByNameInContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :first_name
    remove_column :contacts, :last_name

    add_column :contacts, :name, :string
  end

  def self.down
    remove_column :contacts, :name
  end
end
