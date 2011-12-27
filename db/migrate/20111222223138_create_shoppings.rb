class CreateShoppings < ActiveRecord::Migration
  def self.up
    create_table :shoppings do |t|
      t.integer :user_id
      t.integer :store_id
      t.integer :source

      t.timestamps
    end

    add_index :shoppings, :user_id
    add_index :shoppings, :store_id
    add_index :shoppings, :source

    Product.all.each do |product|
      Shopping.add(
                product.user_id,
                product.store_id,
                ShoppingSource::Product) if product.store_id
    end
  end

  def self.down
    drop_table :shoppings
  end
end
