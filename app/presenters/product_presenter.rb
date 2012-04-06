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

  # Anchor tag for editing the product
  #
  def edit_link
    if h.logged_in? && h.current_user.id == product.user_id
      h.link_to "<i class='icon-pencil'></i> Edit",
                edit_product_path(
                  product.user.handle,
                  product.handle,
                  :src   => 'product'),
                  :style => 'width: 43px;',
                  :class => 'btn'
    end
  end

  # Anchor tag for deleting the product
  #
  def destroy_link
    if h.logged_in? && h.current_user.id == product.user_id
      h.link_to "Delete",
                {:action => 'destroy',:id => product.id},
                :method  => :delete,
                :style   => 'width: 39px;',
                :class   => 'btn',
                :confirm => "Are you sure you want to delete this item?"
    end
  end

  # Link to the next product
  #
  def next(next_product,user)
	    next_product ? 
        h.link_to("<i class='icon-chevron-right'></i>",
                  product_path(user.handle,next_product.handle,:src => 'next'),
                  :class => 'btn') : ''
  end

  # Link to the prev product
  #
  def prev(prev_product,user)
	    prev_product ? 
        h.link_to("<i class='icon-chevron-left'></i>",
                  product_path(user.handle,prev_product.handle,:src => 'previous'),
                  :class => 'btn') : ''
  end

  # Description message for the product used in 
  # og description tag
  #
  def description
    product.store && product.store.is_approved ? 
      "available at #{product.store.name}" : ''
  end


end
