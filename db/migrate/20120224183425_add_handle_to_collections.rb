class AddHandleToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :handle, :string
  end

  def self.down
    remove_column :collections, :handle
  end
end
