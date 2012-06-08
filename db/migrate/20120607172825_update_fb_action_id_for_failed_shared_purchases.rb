class UpdateFbActionIdForFailedSharedPurchases < ActiveRecord::Migration
  def self.up
    Purchase.update_all(
      {:fb_action_id => nil}, 
      {:fb_action_id => FBSharing::Underway})
  end

  def self.down
  end
end
