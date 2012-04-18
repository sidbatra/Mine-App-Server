class RemovingDefaultValuesForFbObjectsInProducts < ActiveRecord::Migration
  def self.up
    Product.update_all({:fb_action_id => nil}, :fb_action_id => '0')
    Product.update_all({:fb_photo_id => nil}, :fb_photo_id => '0')

    change_column :products, :fb_action_id, :string, :default => nil 
    change_column :products, :fb_photo_id, :string, :default => nil 
  end

  def self.down
    change_column :products, :fb_action_id, :string, :default => '0' 
    change_column :products, :fb_photo_id, :string, :default => '0' 
  end
end
