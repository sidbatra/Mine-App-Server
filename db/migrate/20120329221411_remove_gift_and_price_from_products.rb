class RemoveGiftAndPriceFromProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :is_gift
    remove_column :products, :price
  end

  def self.down
  end
end
