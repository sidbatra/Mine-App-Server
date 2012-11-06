class AddEmailMinedTillDateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_mined_till, :datetime
  end

  def self.down
    remove_column :users, :email_mined_till
  end
end
