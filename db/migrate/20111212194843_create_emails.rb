class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.integer :recipient_id
      t.integer :sender_id
      t.integer :emailable_id
      t.string  :emailable_type
      t.string  :message_id
      t.string  :request_id
      t.string  :purpose

      t.timestamps
    end

    add_index :emails,  :recipient_id
    add_index :emails,  :sender_id
    add_index :emails,  [:emailable_id,:emailable_type]
    add_index :emails,  :message_id,  :unique => true
    add_index :emails,  :request_id,  :unique => true  
    add_index :emails,  :purpose
  end

  def self.down
    drop_table :emails
  end
end
