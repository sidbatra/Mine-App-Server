class AddCategoryIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :category_id, :integer

    Product.all.each do |product|
      category = Category.get(product.category)
      product.category_id = category ? category.id : nil
      product.save(false)
    end

    User.update_all :products_count => 0 , :products_price => 0
    (1..8).each{|i| User.update_all "products_#{i}_count" => 0}

    User.all.each do |user|

      user.update_attribute(
            :products_count,
            user.products.reject{|p| p.category_id}.length)

      user.products.each do |product|
        if product.category_id 
          user.add_product_worth(
                product.price ? product.price : 0,
                product.category_id)
        end
      end

    end
  end

  def self.down
    remove_column :products, :category_id
  end
end
