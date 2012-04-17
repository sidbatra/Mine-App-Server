class RemovingSharingFieldsFromProductsTable < ActiveRecord::Migration
  def self.up
    remove_column :products, :shared_to_fb_timeline
    remove_column :products, :shared_to_fb_album
  end

  def self.down
    add_column :products, :shared_to_fb_timeline, :boolean, :default => false
    add_column :products, :shared_to_fb_album, :boolean, :default => false
  end
end
