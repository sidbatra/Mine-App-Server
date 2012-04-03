class AddFbActionIdAndFbPhotoIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :fb_action_id, :string
    add_column :products, :fb_photo_id, :string
  end

  def self.down
    remove_column :products, :fb_action_id
    remove_column :products, :fb_photo_id
  end
end
