class AddImagePathToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :image_path, :string
    add_column :collections, :is_processed, :boolean, :default => false
  end

  def self.down
    remove_column :collections, :image_path
    remove_column :collections, :is_processed
  end
end
