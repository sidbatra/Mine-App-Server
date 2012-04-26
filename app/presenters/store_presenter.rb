# Presenter for the Store model
#
class StorePresenter < BasePresenter
  presents :store
  delegate :name, :to => :store

  # Relative path of the store page.
  #
  def path(src)
    h.store_path(store.handle,:src => src)
  end

  # Absolute url of the store's page.
  #
  def url(src)
    h.store_url(store.handle,:src => src)
  end

  # Description message for the store's use of
  # the app. 
  #
  def usage_description
    "Shop at #{name}? Discover what your friends buy there on "\
    "#{CONFIG[:name]}."
  end

end
