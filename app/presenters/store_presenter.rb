# Presenter for the Store model
#
class StorePresenter < BasePresenter
  presents :store
  delegate :name, :to => :store

  # Relative path of the store's closet
  #
  def closet_path(src)
    h.store_path(store.handle,:src => src)
  end

  # Absolute url of the store's closet
  #
  def closet_url(src)
    h.store_url(store.handle,:src => src)
  end

  # Display html for total products count
  #
  def closet_stats
    h.content_tag(:span, store.products_count.to_s, :class => 'stat_num') +
    " " + (store.products_count == 1 ? 'item' : 'items') + " worth <br />" +
    h.content_tag(:span, h.display_currency(store.products_price), 
      :class => 'stat_num') +
    " bought at this store."
  end

  # Link to larger store photo
  #
  def large_picture(src)
    h.link_to h.image_tag(
                store.large_url, 
                :class  => "user_photo",
                :alt    => ''),
              closet_path(src)
  end

  # Description message for the store's use of
  # the app. 
  #
  def usage_description
    "#{CONFIG[:name]} shows the latest products from #{name} "\
    "that people have in their closets! "\
    "Come check it out!"
  end

  # Unique identifier to be used a source
  #
  def source_id
    "store_" + store.id.to_s
  end

end
