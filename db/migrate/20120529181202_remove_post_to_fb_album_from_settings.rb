class RemovePostToFbAlbumFromSettings < ActiveRecord::Migration
  def self.up
    remove_column :settings, :post_to_fb_album
  end

  def self.down
  end
end
