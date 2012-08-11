class RenamePostToTimelineToShareToFacebook < ActiveRecord::Migration
  def self.up
    rename_column :settings, :post_to_timeline, :share_to_facebook
  end

  def self.down
    rename_column :settings, :share_to_facebook, :post_to_timeline
  end
end
