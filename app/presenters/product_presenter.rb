# Presenter for the Product model
#
class ProductPresenter < BasePresenter
  presents :product
  delegate :thumbnail_url, :to => :product
  delegate :title, :to => :product

  # Relative path for the product
  #
  def path(source)
    h.product_path product.user.handle,product.handle,:src => source
  end
  
  # Absolute path for the product
  # 
  def url(source)
    h.product_url product.user.handle,product.handle,:src => source
  end

  # Description message for the product used in 
  # og description tag
  #
  def description
    product.store && product.store.is_approved ? 
      "available at #{product.store.name}" : ''
  end


end
