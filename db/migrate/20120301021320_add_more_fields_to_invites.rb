class AddMoreFieldsToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :platform, :integer, :default => InvitePlatform::Facebook
    add_column :invites, :recipient_name, :string
    add_column :invites, :byline, :string

    add_index :invites, :platform
  end

  def self.down
    remove_column :invites, :byline
    remove_column :invites, :recipient_name
    remove_column :invites, :platform
  end
end
