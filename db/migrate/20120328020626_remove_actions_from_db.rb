class RemoveActionsFromDb < ActiveRecord::Migration
  def self.up
    remove_column :products, :actions_count
    drop_table :actions
  end

  def self.down
  end
end
