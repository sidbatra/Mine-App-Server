class RemoveImageHostingFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :are_images_hosted
    remove_column :users, :image_path
  end

  def self.down
  end
end
