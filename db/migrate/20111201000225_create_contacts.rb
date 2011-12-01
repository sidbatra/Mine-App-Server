class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :user_id
      t.integer :third_party_id

      t.timestamps
    end

    add_index :contacts, :user_id
    add_index :contacts, :third_party_id
  end

  def self.down
    drop_table :contacts
  end
end
