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

  # Title of the product page
  #
  def page_title(user_name)
    user_name + "'s " + product.title
  end

  # Truncated title
  #
  def preview_title
    h.truncate(product.title, 
            :length 	  => 80, 
            :omissions 	=> '…')
  end

  # Store where the product was bought
  #
  def store_name
    product.store ? product.store.name : ''
  end

  # Description message for the product used in 
  # og description tag
  #
  def description
    product.store && product.store.is_approved ? 
      "available at #{product.store.name}" : ''
  end

  # Link to the store if it is a top store
  #
  def store_link(src)
    link = ""

    if product.store 
      link += h.link_to_if product.store.is_top,
                store_name,
                store_path(product.store.handle,:src => src)
    end

    link
  end

  # Byline displayed on the product show page
  #
  def byline
    html = ""
    
    if product.store
      html += "bought at " +
              store_link('product_store')
    end

    html
  end

  # Shorter product byline 
  #
  def shorter_byline
    html = ""

    if product.store
      html = "Bought at" +
              store_link('product_store')
    end

    html
  end

  # Preview image for the product, along with conditional links in IE
  #
  def preview_image
    h.image_tag product.thumbnail_url, 
                :class    => '',
                :alt      => ''
                # :onclick  => "if($.browser.msie && "\
#                               "parseInt($.browser.version,10) == 7){"\
#                               "window.location="\
#                               "'#{path('profile')}'}"
  end

  # Large product image linked to its original source
  #
  def large_image
    h.link_to h.image_tag(
                  product.photo_url,
                  :id => 'product_image',
                  :alt => ''),
              product.source_url,
              :target => '_blank'
  end

  # id to uniquely identify a product view
  #
  def source_id
    'product_' + product.id.to_s
  end

  # Link to go get back to the source url
  #
  def breadcrumb(title,path)
    h.link_to "<i class='icon-arrow-left'></i> " + title,
              path,
              :style => 'float: left; margin-right: 5px;', 
              :class => 'btn'  
  end


end
