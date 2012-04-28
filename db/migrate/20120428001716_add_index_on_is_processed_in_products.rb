class AddIndexOnIsProcessedInProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :is_processed
  end

  def self.down
    remove_index :products, :is_processed
  end
end
