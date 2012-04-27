class AddPostToFbAlbumInSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :post_to_fb_album, :boolean, :default => true 
  end

  def self.down
    remove_column :settings, :post_to_fb_album
  end
end
