class AddProductsCountToShoppings < ActiveRecord::Migration
  def self.up
    add_column :shoppings, :products_count, :integer, :default => 0

    Shopping.all.each do |shopping|
      shopping.products_count = Product.find_all_by_user_id_and_store_id(
                                          shopping.user_id,
                                          shopping.store_id).count

      if shopping.source == ShoppingSource::Product && shopping.products_count.zero?
        shopping.destroy
      else
        shopping.save!
      end
    end

  end

  def self.down
    remove_column :shoppings, :products_count
  end
end
