class RemoveIsHostedFromProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :is_hosted
  end

  def self.down
  end
end
