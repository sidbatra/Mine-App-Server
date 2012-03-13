# Presenter for the Collection model
#
class CollectionPresenter < BasePresenter
  presents :collection

  # Relative path for the collection 
  #
  def path(source)
    h.collection_path collection.user.handle,collection.handle,:src => source
  end
  
  # Absolute path for the collection 
  # 
  def url(source)
    h.collection_url collection.user.handle,collection.handle,:src => source
  end

  # Anchor tag for editing the collection 
  #
  def edit_link
    if h.logged_in? && h.current_user.id == collection.user_id
      h.link_to "<i class='icon-pencil'></i> Edit",
                edit_collection_path(
                  collection.user.handle,
                  collection.handle,
                  :src => 'collection'),
                :class => 'btn'
    end
  end

  # Anchor tag for deleting the collection 
  #
  def destroy_link
    if h.logged_in? && h.current_user.id == collection.user_id
      h.link_to "Delete",
                {:action => 'destroy',:id => collection.id},
                :method => :delete,
                :class => 'btn',
                :confirm  => "Are you sure you want to delete this set?"
    end
  end

  # Link to the next collection 
  #
  def next(next_collection,user)
	    next_collection ? 
        h.link_to(
            "<i class='icon-chevron-right'></i>",
            collection_path(user.handle,next_collection.handle,:src => 'next'),
            :class => 'btn') : ''
  end

  # Link to the prev collection 
  #
  def prev(prev_collection,user)
	    prev_collection ? 
        h.link_to(
            "<i class='icon-chevron-left'></i>",
            collection_path(user.handle,prev_collection.handle,:src => 'previous'),
            :class => 'btn') : ''
  end

  # Link to go get back to the source url
  #
  def breadcrumb(title,path)
    h.link_to "<i class='icon-arrow-left'></i> " + title,
              path,
              :style => 'float: left; margin-right: 5px;', 
              :class => 'btn' 
  end

  # Title of the page
  #
  def page_title(user_name)
    collection.name.present? ? collection.name : user_name + "'s set"
  end

  # Description message for the collection used in
  # og description tag
  #
  def description
    description   = h.pluralize(collection.products.length, "item", "items")

    stores        = collection.products.map(&:store).uniq
    names         = stores.compact.map{|s| s.name if s.is_approved}.compact

    other_stores  = stores.include?(nil) || (stores.length != names.length)  
      
    if names.present? 
      description += " from " 

      if names.length == 1
        description += names[0]
      else
        description += names[0..-2].join(", ") + 
                       (other_stores ? ", " : " and ") + 
                       names[-1] 
      end

      description += " and others" if other_stores
    end

    description
  end


  # Thumbnail url for the collection
  #
  def thumbnail_url
    collection.is_processed ? collection.image_url : 
                              collection.products.first.thumbnail_url
  end

end
