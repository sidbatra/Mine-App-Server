class RemoveFbPhotoIdFromPurchases < ActiveRecord::Migration
  def self.up
    remove_column :purchases, :fb_photo_id
  end

  def self.down
    add_column :purchases, :fb_photo_id, :string
  end
end
