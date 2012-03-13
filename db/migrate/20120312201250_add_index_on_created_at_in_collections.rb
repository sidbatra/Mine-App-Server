class AddIndexOnCreatedAtInCollections < ActiveRecord::Migration
  def self.up
    add_index :collections, :created_at
  end

  def self.down
    remove_index :collections, :created_at
  end
end
