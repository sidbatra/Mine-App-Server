class AddCampaignToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :campaign, :string
  end

  def self.down
    remove_column :users, :campaign
  end
end
