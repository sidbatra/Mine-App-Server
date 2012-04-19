class ChangingDefaultValuesForFbObjectsInProducts < ActiveRecord::Migration
  def self.up
    Product.update_all({:fb_action_id => '0'}, :fb_action_id => nil)
    Product.update_all({:fb_photo_id => '0'}, :fb_photo_id => nil)

    change_column :products, :fb_action_id, :string, :default => '0'
    change_column :products, :fb_photo_id, :string, :default => '0'
  end

  def self.down
    change_column :products, :fb_action_id, :string, :default => nil 
    change_column :products, :fb_photo_id, :string, :default => nil
  end
end
