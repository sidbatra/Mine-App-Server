class AddTumblrFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tumblr_access_token, :string
    add_column :users, :tumblr_access_token_secret, :string
    add_column :users, :tumblr_user_id, :string
  end

  def self.down
    remove_column :users, :tumblr_access_token
    remove_column :users, :tumblr_access_token_secret
    remove_column :users, :tumblr_user_id
  end
end
