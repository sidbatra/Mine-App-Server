class AddExtraColumnsInSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :email_digest, :boolean, :default => true
    add_column :settings, :email_follower, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :email_digest
    remove_column :settings, :email_follower
  end
end
