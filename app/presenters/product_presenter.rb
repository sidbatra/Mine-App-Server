# Presenter for the Product model
#
class ProductPresenter < BasePresenter
  presents :product
  delegate :thumbnail_url, :to => :product
  delegate :title, :to => :product

  # Relative path for the product
  #
  def path(source)
    h.product_path product.id,product.handle,:src => source
  end
  
  # Absolute path for the product
  # 
  def url(source)
    h.product_url product.id,product.handle,:src => source
  end

  # Anchor tag for deleting the product
  #
  def destroy_link
    if h.current_user.id == product.user_id
      h.link_to "Delete this item",
                {:action => 'destroy',:id => product.id},
                :method => :delete
    end
  end

  # Link to the next product
  #
  def next(path)
	    path ? h.link_to('',path,:class => 'next') : ''
  end

  # Link to the prev product
  #
  def prev(path)
	    path ? h.link_to('',path,:class => 'previous') : ''
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

  # Price of the product
  #
  def price
    product.price ? h.display_currency(product.price) : ''
  end

  # Byline displayed on the product show page
  #
  def byline
    html = ""
    
    if product.price
      html += "for <span class='right_price'>" + 
              price +
              "</span> " +
              "at <span class='right_store'>" +
              store_name
              "</span>"
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

  # Large product image linked to it's original source
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

end
