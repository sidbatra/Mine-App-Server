class RemoveFbPermissionFieldsFromSetting < ActiveRecord::Migration
  def self.up
    remove_column :settings, :fb_publish_actions
    remove_column :settings, :fb_publish_stream
  end

  def self.down
    add_column :settings, :fb_publish_actions, :boolean
    add_column :settings, :fb_publish_stream, :boolean
  end
end
