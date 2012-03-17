class AddIndexOnTitleInProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :title
  end

  def self.down
    remove_index :products, :title
  end
end
