class AddCountersToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :comments_count, :integer, :default => 0
    add_column :collections, :actions_count, :integer, :default => 0
  end

  def self.down
    remove_column :collections, :actions_count
    remove_column :collections, :comments_count
  end
end
