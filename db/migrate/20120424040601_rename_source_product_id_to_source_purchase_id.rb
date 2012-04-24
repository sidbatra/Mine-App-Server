class RenameSourceProductIdToSourcePurchaseId < ActiveRecord::Migration
  def self.up
    remove_index :purchases, :source_product_id
    rename_column :purchases, :source_product_id, :source_purchase_id
    add_index :purchases, :source_purchase_id
  end

  def self.down
    remove_index :purchases, :source_purchase_id
    rename_column :purchases, :source_purchase_id, :source_product_id
    add_index :purchases, :source_product_id
  end
end
