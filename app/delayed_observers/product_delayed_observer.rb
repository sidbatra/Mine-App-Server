class ProductDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(product_id)
    product = Product.find(product_id)
    product.host

    unless product.tags.present?
      product.tags = ProductTagger.new(product.source_url,product.external_id).tags
      product.save!
    end
  end

end
