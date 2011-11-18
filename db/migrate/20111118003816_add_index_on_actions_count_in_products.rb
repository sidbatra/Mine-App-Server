class AddIndexOnActionsCountInProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :actions_count
  end

  def self.down
    remove_index :products, :actions_count
  end
end
