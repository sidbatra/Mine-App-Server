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

  # Anchor tag for deleting the product
  #
  def edit_link
    if h.logged_in? && h.current_user.id == product.user_id
      h.link_to "Edit",
                edit_product_path(
                  product.user.handle,
                  product.handle,
                  :src => 'product'),
                 :class => 'edit_cccccc_14'
    end
  end

  # Anchor tag for deleting the product
  #
  def destroy_link
    if h.logged_in? && h.current_user.id == product.user_id
      h.link_to "Delete",
                {:action => 'destroy',:id => product.id},
                :method => :delete,
                :class => '',
                :confirm  => "Are you sure you want to delete this item?"
    end
  end

  # Link to the next product
  #
  def next(next_product,user)
	    next_product ? 
        h.link_to('',
                  product_path(user.handle,next_product.handle,:src => 'next'),
                  :class => 'next') : ''
  end

  # Link to the prev product
  #
  def prev(prev_product,user)
	    prev_product ? 
        h.link_to('',
                  product_path(user.handle,prev_product.handle,:src => 'previous'),
                  :class => 'previous') : ''
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

  # Open graph type
  #
  def og_type
    "#{CONFIG[:fb_app_namespace]}:item"
  end

  # Store where the product was bought
  #
  def store_name
    product.store ? product.store.name : ''
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
    
    if product.is_gift
      html += "as a gift "
    end

    if product.store
      html += "bought " if product.is_gift

      html += "at <span class='right_store'>" +
              store_link('product_store') +
              "</span>"
    end

    html
  end

  # Shorter product byline displayed on the user and collection show page
  #
  def shorter_byline
    html = ""

    if product.store
      html = "Bought at <span class='right_store'>" +
              store_link('collection_store') +
              "</span>"
    elsif product.is_gift
      html = "gift "
    end

    html
  end

  # Preview image for the product, along with conditional links in IE
  #
  def preview_image
    h.image_tag product.thumbnail_url, 
                :class    => 'product_left_image',
                :alt      => ''
                # :onclick  => "if($.browser.msie && "\
#                               "parseInt($.browser.version,10) == 7){"\
#                               "window.location="\
#                               "'#{path('profile')}'}"
  end

  # Large product image linked to its original source
  #
  def large_image
    h.link_to_if !product.is_hosted,
                  h.image_tag(
                    product.photo_url,
                    :id => 'left_photo',
                    :alt => ''),
                  product.source_url,
                  :target => '_blank'
  end

  # Generate html for the comment bubble used in the preview
  #
  def comment_bubble
    html = ""

    if product.comments_count != 0
      html += product.comments_count.to_s + ' '
      html += h.image_tag 'comment_bubble.png', 
                :class => 'product_comment_bubble',
                :alt => ''
    end

    html
  end

  # id to uniquely identify a product view
  #
  def source_id
    'product_' + product.id.to_s
  end

  # Link to go get back to the source url
  #
  def breadcrumb(title,path)
    h.link_to "<span class='unicode'>←</span> " + title,
              path,
              :class => '' 
  end


end
