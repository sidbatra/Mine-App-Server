class AddNewImageColumnsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :image_path, :string
    add_column :products, :is_processed, :boolean, :default => false

    add_index :products, :is_processed

    Product.find_all_by_is_hosted(true).each do |product|
      product.image_path = product.orig_image_url
      product.save(false)
    end
  end

  def self.down
    remove_column :products, :is_processed
    remove_column :products, :image_path
  end
end
