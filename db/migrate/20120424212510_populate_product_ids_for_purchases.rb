class PopulateProductIdsForPurchases < ActiveRecord::Migration
  def self.up
    image_urls_hash = {}

    Product.select(:id,:orig_image_url).each do |product| 
      image_urls_hash[product.orig_image_url] = product.id
    end

    columns = [:id,:product_id,:source_purchase_id]
    values = []

    Purchase.all.each do |purchase|
      values << [purchase.id,
                  image_urls_hash[purchase.orig_image_url],
                  purchase.source_purchase_id.to_i.zero? ? 
                    nil : 
                    purchase.source_purchase_id]
    end

    Purchase.import columns,
      values, {
        :validate => false,
        :timestamps => false,
        :on_duplicate_key_update => [:source_purchase_id,:product_id]}
  end

  def self.down
    Purchase.update_all :product_id => nil
  end
end
