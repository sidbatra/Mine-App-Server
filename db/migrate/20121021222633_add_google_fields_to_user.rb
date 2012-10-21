class AddGoogleFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :go_email, :string
    add_column :users, :go_token, :string
    add_column :users, :go_secret, :string
  end

  def self.down
    remove_column :users, :go_secret
    remove_column :users, :go_token
    remove_column :users, :go_email
  end
end
