class AddHasContactsMinedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :has_contacts_mined, :boolean, :default => false
  end

  def self.down
    remove_column :users, :has_contacts_mined
  end
end
