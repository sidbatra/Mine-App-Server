# Presenter for the Collection model
#
class CollectionPresenter < BasePresenter
  presents :collection

  # Relative path for the collection 
  #
  def path(source)
    h.collection_path collection.user.handle,collection.id,:src => source
  end
  
  # Absolute path for the collection 
  # 
  def url(source)
    h.collection_url collection.user.handle,collection.id,:src => source
  end

  # Anchor tag for editing the collection 
  #
  def edit_link
    if h.logged_in? && h.current_user.id == collection.user_id
      h.link_to "Edit",
                edit_collection_path(
                  collection.user.handle,
                  collection.id,
                  :src => 'collection'),
                :class => 'edit_cccccc_14'
    end
  end

  # Anchor tag for deleting the collection 
  #
  def destroy_link
    if h.logged_in? && h.current_user.id == collection.user_id
      h.link_to "Delete",
                {:action => 'destroy',:id => collection.id},
                :method => :delete,
                :class => '',
                :confirm  => "Are you sure you want to delete this set?"
    end
  end

  # Link to the next collection 
  #
  def next(next_collection,user)
	    next_collection ? 
        h.link_to(
            '',
            collection_path(user.handle,next_collection.id,:src => 'next'),
            :class => 'next') : ''
  end

  # Link to the prev collection 
  #
  def prev(prev_collection,user)
	    prev_collection ? 
        h.link_to(
            '',
            collection_path(user.handle,prev_collection.id,:src => 'previous'),
            :class => 'previous') : ''
  end

  # Link to go get back to the source url
  #
  def breadcrumb(title,path)
    h.link_to "<span class='unicode'>←</span> " + title,
              path,
              :class => '' 
  end

  # Title of the page
  #
  def page_title(user_name)
    "A set of items owned by " + user_name
  end

end
