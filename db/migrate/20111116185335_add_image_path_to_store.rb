class AddImagePathToStore < ActiveRecord::Migration
  def self.up
    add_column :stores, :image_path, :string
    add_column :stores, :is_processed, :boolean, :default => false

    add_index :stores, :is_processed
  end

  def self.down
    remove_column :stores, :is_processed
    remove_column :stores, :image_path
  end
end
