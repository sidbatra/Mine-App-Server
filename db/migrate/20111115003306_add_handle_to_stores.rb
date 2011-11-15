class AddHandleToStores < ActiveRecord::Migration
  def self.up
    add_column :stores, :handle, :string
    add_index :stores, :handle, :unique => true

    Store.all.each{|store| store.save}
  end

  def self.down
    remove_column :stores, :handle
  end
end
