class RemoveCrawlableFromStores < ActiveRecord::Migration
  def self.up
    remove_column :stores, :crawlable
  end

  def self.down
    add_column :stores, :crawlable, :boolean, :default => false
  end
end
