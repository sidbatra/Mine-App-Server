class AddNameToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :name, :string, :default => ''
  end

  def self.down
    remove_column :collections, :name
  end
end
