class AddThemeIdToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :theme_id, :integer, :default => Theme.default.id
  end

  def self.down
    remove_column :settings, :theme_id
  end
end
