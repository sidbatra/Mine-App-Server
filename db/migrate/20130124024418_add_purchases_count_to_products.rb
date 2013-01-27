class AddPurchasesCountToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :purchases_count, :integer, :default => 0

    columns = [:id,:purchases_count]

    Product.with_purchases.find_in_batches(:batch_size => 1000) do |batch|
      values = []

      batch.each do |product|
        values << [product.id,product.purchases.length]
      end

      Product.import(columns,values,{
              :validate => false,
              :timestamps => false,
              :on_duplicate_key_update => [:purchases_count]})
    end

  end

  def self.down
    remove_column :products, :purchases_count
  end
end
