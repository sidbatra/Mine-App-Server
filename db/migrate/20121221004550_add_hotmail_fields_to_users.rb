class AddHotmailFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hm_email, :string
    add_column :users, :hm_password, :string
  end

  def self.down
    remove_column :users, :hm_password
    remove_column :users, :hm_email
  end
end
