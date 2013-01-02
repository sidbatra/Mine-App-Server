class AddEmailMiningMetadataToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_mining_metadata, :string
  end

  def self.down
    remove_column :users, :email_mining_metadata
  end
end
