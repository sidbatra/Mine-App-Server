class AddYahooAuthFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :yh_token, :string
    add_column :users, :yh_secret, :string
    add_column :users, :yh_email, :string
    add_column :users, :yh_session_handle, :string
  end

  def self.down
    remove_column :users, :yh_session_handle
    remove_column :users, :yh_email
    remove_column :users, :yh_secret
    remove_column :users, :yh_token
  end
end
