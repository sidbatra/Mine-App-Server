class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :first_name
      t.string    :last_name
      t.string    :gender
      t.string    :email
      t.datetime  :birthday
      t.string    :fb_user_id
      t.string    :access_token
      t.string    :remember_token
      t.datetime  :remember_token_expires_at
      t.boolean   :is_admin, :default => false

      t.timestamps
    end

    add_index :users, :email, :unique => true
    add_index :users, :remember_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
