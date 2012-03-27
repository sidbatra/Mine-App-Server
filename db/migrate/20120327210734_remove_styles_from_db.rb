class RemoveStylesFromDb < ActiveRecord::Migration
  def self.up
    remove_column :invites, :style_id
    remove_column :users, :style_id
    drop_table :styles
  end

  def self.down
  end
end
