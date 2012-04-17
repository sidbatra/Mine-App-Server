class AddSharingFieldsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :shared_to_fb_timeline, :boolean, :default => false
    add_column :products, :shared_to_fb_album, :boolean, :default => false
  end

  def self.down
    remove_column :products, :shared_to_fb_timeline
    remove_column :products, :shared_to_fb_album
  end
end
