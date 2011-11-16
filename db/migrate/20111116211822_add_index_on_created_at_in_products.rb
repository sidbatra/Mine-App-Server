class AddIndexOnCreatedAtInProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :created_at
    add_index :products, :comments_count
  end

  def self.down
    remove_index :products, :created_at
    remove_index :products, :comments_count
  end
end
