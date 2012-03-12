class AddIndexOnCollectionsHandle < ActiveRecord::Migration
  def self.up
    add_index :collections, :handle
  end

  def self.down
    remove_index :collections, :handle
  end
end
