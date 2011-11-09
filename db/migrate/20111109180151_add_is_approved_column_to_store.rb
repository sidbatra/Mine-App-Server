class AddIsApprovedColumnToStore < ActiveRecord::Migration
  def self.up
    add_column :stores, :is_approved, :boolean, :default => false
    add_index  :stores, :is_approved

    Store.all[0..574].each do |store|
      store.is_approved = true
      store.save(false)
    end
  end

  def self.down
    remove_column :stores, :is_approved
  end
end
