class AddIndexOnUserContactsMined < ActiveRecord::Migration
  def self.up
    add_index :users, :has_contacts_mined
  end

  def self.down
    remove_index :users, :has_contacts_mined
  end
end
