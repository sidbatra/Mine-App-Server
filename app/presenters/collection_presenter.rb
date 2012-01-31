# Presenter for the Collection model
#
class CollectionPresenter < BasePresenter
  presents :collection

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

end
