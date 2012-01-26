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
    "<meta name='asset_host' content='#{ActionController::Base.asset_host}'/>"
  end

  # Generate a meta tag for the current user id 
  #
  def current_user_id_meta_tag
    current_user_id = logged_in? ? self.current_user.id : 0
    "<meta name='current_user_id' content='#{current_user_id}'/>"
  end

  # Generate meta tag for status of onboarding
  #
  def is_onboarding_meta_tag
    "<meta name='is_onboarding' content='#{is_onboarding?}'/>"
  end

  # Generate meta tag for application version
  #
  def version_meta_tag
    "<meta name='version' content='#{CONFIG[:version]}'/>"
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

  # Link to the contact email
  #
  def email_link
    "<a href='mailto:#{EMAILS[:contact]}'>" +
      EMAILS[:contact].split(' ').last[1..-2] + "</a>"
  end

  # Whether the user is undergoing onboarding 
  #
  def is_onboarding?
    request.request_uri.scan(/^\/welcome\//).present?
  end

  # Whether the user is on the onboarding create view
  #
  def is_onboarding_create?
    is_onboarding? && 
      @controller.controller_name == 'products' &&
      @controller.action_name == 'new'
  end

end
