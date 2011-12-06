class ChangeRecipientIdToStringInInvites < ActiveRecord::Migration
  def self.up
    change_column :invites, :recipient_id, :string
  end

  def self.down
    change_column :invites, :recipient_id, :integer
  end
end
