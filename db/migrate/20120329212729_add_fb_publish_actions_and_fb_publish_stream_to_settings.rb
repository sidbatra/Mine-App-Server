class AddFbPublishActionsAndFbPublishStreamToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :fb_publish_actions, :boolean, :default => true 
    add_column :settings, :fb_publish_stream, :boolean, :default => false 
  end

  def self.down
    remove_column :settings, :fb_publish_actions
    remove_column :settings, :fb_publish_stream
  end
end
