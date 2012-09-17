class AddMessageToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :message, :string
  end

  def self.down
    remove_column :invites, :message
  end
end
