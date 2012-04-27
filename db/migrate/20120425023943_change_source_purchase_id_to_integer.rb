class ChangeSourcePurchaseIdToInteger < ActiveRecord::Migration
  def self.up
    remove_index :purchases, :source_purchase_id
    change_column :purchases, :source_purchase_id, :integer
  end

  def self.down
    add_index :purchases, :source_purchase_id
    change_column :purchases, :source_purchase_id, :string
  end
end
