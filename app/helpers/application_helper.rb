# Application wide helpers
#
module ApplicationHelper

  # Generate a presenter object for the given class
  # object. Defaults to "#{ObjetClass}Presenter" when
  # klass is nil.
  #
  def presenter_for(object,klass = nil)
    klass     ||= "#{object.class}Presenter".constantize
    presenter   = klass.new(object, self)

    presenter
  end

  # Generate a meta tag to declare the asset host for use by
  # javascript
  #
  def asset_host_meta_tag
    "<meta name='asset_host' content='#{CONFIG[:asset_host]}'/>"
  end

  # Format price or currency in general
  #
  def display_currency(amount)
    '$' + ('%.2f' % amount).chomp('.00')
  end

  # Blocker tells browser to break float layouts
  #
  def blocker
    "<div id='blocker'></div>"
  end

end
