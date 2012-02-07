class AddIndexesOnActions < ActiveRecord::Migration
  def self.up
    add_index :actions, :name
    add_index :actions, :created_at
  end

  def self.down
    remove_index :actions, :name
    remove_index :actions, :created_at
  end
end
