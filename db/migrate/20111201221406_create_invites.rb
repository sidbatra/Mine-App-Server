class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer :user_id
      t.integer :recipient_id

      t.timestamps
    end

    add_index :invites, [:user_id,:recipient_id], :unique => true
    add_index :invites, :recipient_id
  end

  def self.down
    drop_table :invites
  end
end
