class AddMetadataFieldsToStores < ActiveRecord::Migration
  def self.up
    add_column :stores, :domain, :string 
    add_column :stores, :byline, :string 
    add_column :stores, :description, :text 
    add_column :stores, :favicon_path, :string
  end

  def self.down
    remove_column :stores, :domain, :string 
    remove_column :stores, :byline, :string 
    remove_column :stores, :description, :text 
    remove_column :stores, :favicon_path, :string
  end
end
