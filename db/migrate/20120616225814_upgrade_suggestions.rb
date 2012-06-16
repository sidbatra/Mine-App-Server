class UpgradeSuggestions < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :short_title, :string
    add_column :suggestions, :small_image_path, :string
    add_column :suggestions, :thing, :string
    add_column :suggestions, :example, :string
  end

  def self.down
    remove_column :suggestions, :short_title
    remove_column :suggestions, :small_image_path
    remove_column :suggestions, :thing
    remove_column :suggestions, :example
  end
end
