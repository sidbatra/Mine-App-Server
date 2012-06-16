class AddTumblrPostIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :tumblr_post_id, :string
  end

  def self.down
    remove_column :purchases, :tumblr_post_id
  end
end
