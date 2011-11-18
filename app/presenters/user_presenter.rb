# Presenter for the User model
#
class UserPresenter < BasePresenter
  presents :user
  delegate :first_name, :to => :user

  # Full name of the user
  #
  def full_name
    user.first_name + ' ' + user.last_name
  end

  # He / she
  #
  def pronoun
    user.is_male? ? 'he' : 'she'
  end

  # His / her
  #
  def possessive_pronoun
    user.is_male? ? 'his' : 'her'
  end

  # Generic bought text with
  #
  def bought_text
    full_name + ' bought ' + possessive_pronoun
  end

  # Large display picture on the profile
  #
  def large_picture(klass,src='picture')
    h.link_to h.image_tag(
                user.photo_url, 
                :class  => "#{klass} slim_shadow_dark",
                :alt    => ''),
              closet_path(src)
  end

  # Display name for the user's closet
  #
  def closet_name
    user.first_name + "'s Closet"
  end

  # Full title of the closet
  #
  def closet_title
    name  = self.full_name

    if name.length >= 20
      parts = name.split(/ |-/)
      name  = parts.first + ' ' + parts.last if parts.length > 2
    end

    name + "'s Closet"
  end

  # Full url of the user's closet
  #
  def closet_url(src)
    h.user_url(user.handle,:src => src)
  end

  # Relative path of the user's closet
  #
  def closet_path(src)
    h.user_path(user.handle,:src => src)
  end

  # Link to go get back to the closet
  #
  def closet_breadcrumb(src)
    h.link_to "← " + user.first_name + "'s closet",
              closet_path(src),
              :class => 'navigation slim_shadow_light' 
  end

  # Image representing the closet - image of
  # last product uploaded
  #
  def closet_image(products)
    products.present? ? products.first.thumbnail_url : ''
  end

  # Display html for total products count
  #
  def closet_stats
    h.content_tag(:span, user.products_count.to_s, :class => 'stat_num') +
    " " + (user.products_count == 1 ? 'item' : 'items') + " worth <br />" +
    h.content_tag(:span, h.display_currency(user.products_price), 
      :class => 'stat_num') +
    " in " + 
    (h.is_current_user(user) ? 'your' : user.first_name + "'s") +
    " closet."
  end

  # Generate links for creating in different categories
  #
  def closet_create_links(categories)
    text = ""

    categories.each do |category|
      text += h.link_to category.id == 8 ? 
                          "Add anything!" :
                          "Add your #{category.name.downcase} ›",
                        new_product_path(
                          :category => category.handle,
                          :src      => 'profile'),
                        :class => 'suggestion hover_shadow_light'
    end

    text
  end

  # Generate links for creating in different categories from near
  # the filter links
  #
  def closet_create_links_near_filters(categories)
	  html = ""
    
    if h.is_current_user(user)
      categories.each do |category|
        html += h.link_to "Add ›<br/>",
                          new_product_path(
                            :category => category.handle,
                            :src => "filters")
      end
    end

    html
  end

  # Generate filter links for the closet
  #
  def closet_filter_links(categories)
    html = ""

    html += h.link_to_if user.products_count > 0,
                    "View all <span class='cat_num'>" + 
                    (user.products_count > 0 ? user.products_count.to_s : '') +
                    "</span><br/>",
                  '#all' 

		html += "<ul>"
		
    categories.each do |category|
      category_count = user.products_category_count(category.id) 

      html += h.link_to_if category_count != 0,
      							"<li>" +
                  	category.name +  
                    " <span class='cat_num'>" +
                    category_count.to_s +
                    "</span></li>",
                    "##{category.handle}"
    end
    
    html += "</ul>"

    html
  end

  # Message displaying people you're following
  #
  def following_message
    message = ""

    if user.ifollowers.present?
      message = h.is_current_user(user) ? 
                  "People you're following" : 
                  user.first_name + " is following"
    else
      message = h.is_current_user(user) ?
                  "People you're following" : 
                  user.first_name + " isn't following anyone yet."
    end

    message
  end

  # Description message for the user's use of
  # the app. 
  #
  def usage_description
    user.first_name + " is using Felvy to share what " +
    (user.is_male? ? "he" : "she") +
    " buys and owns. Its fun, and free!"
  end

  # Unique identifier to be used a source
  #
  def source_id
    "user_" + user.id.to_s
  end


end
