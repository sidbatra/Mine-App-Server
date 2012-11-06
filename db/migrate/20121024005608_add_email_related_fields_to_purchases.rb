class AddEmailRelatedFieldsToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :source, :integer, :default => 0
    add_column :purchases, :is_approved, :boolean, :default => true
    add_column :purchases, :bought_at, :timestamp


    columns = [:id,:bought_at]
    values = []

    Purchase.with_product.find_in_batches(:batch_size => 500) do |batch|
      batch.each do |purchase|
        values << [purchase.id,purchase.created_at]
      end
    end

    Purchase.import columns,values,
      {:validate => false,
      :timestamps => false,
      :on_duplicate_key_update => [:bought_at]}


    add_index :purchases, :bought_at
    add_index :purchases, :is_approved
    remove_index :purchases, :created_at
  end

  def self.down
    add_index :purchases, :created_at

    remove_column :purchases, :bought_at
    remove_column :purchases, :is_approved
    remove_column :purchases, :source
  end
end
