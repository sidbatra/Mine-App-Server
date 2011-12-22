class AddIndexOnGenderAndBirthdayInUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :gender
    add_index :users, :birthday
  end

  def self.down
    remove_index :users, :gender
    remove_index :users, :birthday
  end
end
