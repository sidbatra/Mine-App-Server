class AddShareToTwitterToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :share_to_twitter, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :share_to_twitter
  end
end
