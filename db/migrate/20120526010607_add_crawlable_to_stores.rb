class AddCrawlableToStores < ActiveRecord::Migration
  def self.up
    add_column :stores, :crawlable, :boolean, :default => false
  end

  def self.down
    remove_column :stores, :crawlable
  end
end
