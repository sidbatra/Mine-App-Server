class AddImageFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :image_path, :string
    add_column :users, :are_images_hosted, :boolean, :default => false
  end

  def self.down
    remove_column :users, :are_images_hosted
    remove_column :users, :image_path
  end
end
