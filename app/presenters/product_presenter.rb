# Presenter for the Product model
#
class ProductPresenter < BasePresenter
  presents :product

  # Url for the product
  #
  def url(source)
    h.product_path product.id,product.handle,:src => source
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

  # Preview image for the product, along with conditional links in IE
  #
  def preview_image
    h.image_tag product.thumbnail_url, 
                :class    => 'product_left_image',
                :alt      => '',
                :onclick  => "if($.browser.msie && "\
                              "parseInt($.browser.version,10) == 7){"\
                              "window.location="\
                              "'#{url('profile')}'}"
  end

  # Generate html for the comment bubble used in the preview
  #
  def comment_bubble
    html = ""

    if product.comments_count != 0
      html += product.comments_count.to_s + ' '
      html += h.image_tag 'comment_bubble.gif', 
                :class => 'product_comment_bubble',
                :alt => ''
    end

    html
  end

end
