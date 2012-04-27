class AddProductIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :product_id, :integer
    change_column :purchases, :orig_thumb_url, :text
  end

  def self.down
    remove_column :purchases, :product_id
    change_column :purchases, :orig_thumb_url, :string
  end
end
