class RenameProductImageUrls < ActiveRecord::Migration
  def self.up
    rename_column :products, :thumb_url,    :orig_thumb_url
    rename_column :products, :image_url,    :orig_image_url
    rename_column :products, :website_url,  :source_url
  end

  def self.down
    rename_column :products, :orig_thumb_url, :thumb_url
    rename_column :products, :orig_image_url, :image_url
    rename_column :products, :source_url,     :website_url
  end
end
