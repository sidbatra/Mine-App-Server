class CreatePurchaseEmails < ActiveRecord::Migration
  def self.up
    create_table :purchase_emails do |t|
      t.integer :purchase_id
      t.string :message_id
      t.integer :provider
      t.text :text

      t.timestamps
    end

    add_index :purchase_emails, :purchase_id, :unique => true
  end

  def self.down
    drop_table :purchase_emails
  end
end
