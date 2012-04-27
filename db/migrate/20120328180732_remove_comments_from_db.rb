class RemoveCommentsFromDb < ActiveRecord::Migration
  def self.up
    remove_column :products, :comments_count
    drop_table :comments
  end

  def self.down
  end
end
