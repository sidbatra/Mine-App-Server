class RemoveCollectionsAndCollectionPartFromDb < ActiveRecord::Migration
  def self.up
    remove_column :users, :collections_count
    drop_table :collection_parts
    drop_table :collections
  end

  def self.down
  end
end
