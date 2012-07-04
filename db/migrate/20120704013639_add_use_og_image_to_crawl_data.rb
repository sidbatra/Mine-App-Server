class AddUseOgImageToCrawlData < ActiveRecord::Migration
  def self.up
    add_column :crawl_data, :use_og_image, :boolean, :default => false
  end

  def self.down
    remove_column :crawl_data, :use_og_image
  end
end
