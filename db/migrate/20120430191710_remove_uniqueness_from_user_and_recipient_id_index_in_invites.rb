class RemoveUniquenessFromUserAndRecipientIdIndexInInvites < ActiveRecord::Migration
  def self.up
    remove_index :invites, [:user_id,:recipient_id]
    add_index :invites, [:user_id,:recipient_id]
  end

  def self.down
    remove_index :invites, [:user_id,:recipient_id]
    add_index :invites, [:user_id,:recipient_id], :unique => true
  end
end
