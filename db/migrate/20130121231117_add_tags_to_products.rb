class AddTagsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :tags, :text
  end

  def self.down
    remove_column :products, :tags
  end
end
