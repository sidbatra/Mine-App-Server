class RenameCampaignToSourceInUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :campaign, :source
  end

  def self.down
    rename_column :users, :source, :campaign
  end
end
