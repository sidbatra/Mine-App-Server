class AddShareToTumblrToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :share_to_tumblr, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :share_to_tumblr
  end
end
