class AddWeightToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :weight, :integer, :default => 0
    add_index :contacts, :weight
  end

  def self.down
    remove_column :contacts, :weight
  end
end
