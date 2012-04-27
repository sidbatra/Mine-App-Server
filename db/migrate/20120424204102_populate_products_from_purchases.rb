class PopulateProductsFromPurchases < ActiveRecord::Migration
  def self.up
    image_urls_hash = {}

    columns = [:title,:source_url,:orig_image_url,
                :orig_image_url_hash,:external_id]
    values = []

    Purchase.all.each do |purchase|
      next if image_urls_hash.key?(purchase.orig_image_url)

      if purchase.source_purchase_id.to_i.zero?
        unique_id = purchase.source_purchase_id
      else
        unique_id = nil
      end

      values << [purchase.title,
                  purchase.source_url,
                  purchase.orig_image_url,
                  Digest::SHA1.hexdigest(purchase.orig_image_url),
                  unique_id]

      image_urls_hash[purchase.orig_image_url] = true
    end

    Product.import columns,values,{:validate => false}
  end

  def self.down
    Product.delete_all
    ActiveRecord::Base.connection.execute "ALTER TABLE products AUTO_INCREMENT=1"
  end
end
