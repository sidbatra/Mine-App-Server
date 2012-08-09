class AddIphoneDeviceTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :iphone_device_token, :string
  end

  def self.down
    remove_column :users, :iphone_device_token
  end
end
