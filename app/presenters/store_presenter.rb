# Presenter for the Store model
#
class StorePresenter < BasePresenter
  presents :store

  # Display html for total products count
  #
  def closet_stats
    h.content_tag(:span, store.products_count.to_s, :class => 'stat_num') +
    " " + (store.products_count == 1 ? 'item' : 'items') + " worth <br />" +
    h.content_tag(:span, h.display_currency(store.products_price), 
      :class => 'stat_num') +
    " bought at this store."
  end

  # Generate filter links for the closet
  #
  def closet_filter_links(categories)
    html = ""

    html += h.link_to_if store.products_count > 0,
                    "View all <span class='cat_num'>" + 
                    (store.products_count > 0 ? store.products_count.to_s : '') +
                    "</span><br/>",
                  '#all' 

		html += "<ul>"
		
    categories.each do |category|
      category_count = store.products_category_count(category.id) 

      html += h.link_to(
      							"<li>" +
                  	category.name +  
                    " <span class='cat_num'>" +
                    category_count.to_s +
                    "</span></li>",
                    "##{category.handle}") if category_count != 0
    end
    
    html += "</ul>"

    html
  end

end
