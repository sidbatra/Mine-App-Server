class AddHandleToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :handle, :string

    Collection.all.each{|c| c.save!}
  end

  def self.down
    remove_column :collections, :handle
  end
end
