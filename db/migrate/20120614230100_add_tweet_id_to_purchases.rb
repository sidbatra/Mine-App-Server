class AddTweetIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :tweet_id, :string
  end

  def self.down
    remove_column :purchases, :tweet_id
  end
end
