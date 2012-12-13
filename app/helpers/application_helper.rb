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

  # Generate a meta tag for the gender of the current user
  #
  # returns - String. HTML meta tag for the current user's gender
  #
  def current_user_gender_meta_tag
    current_user_gender = logged_in? && self.current_user.gender.present? ? 
                            self.current_user.gender :
                            'unknown'
    "<meta name='current_user_gender' content='#{current_user_gender}'/>"
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

  # Format currency for display
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
    "<a href='mailto:#{contact_email}'>Contact</a>"
  end

  # Public. Extract actual contact email from EMAILS to field.
  #
  # returns a String contact email.
  #
  def contact_email
    EMAILS[:contact].split(' ').last[1..-2] 
  end

  # Whether the user is undergoing onboarding 
  #
  def is_onboarding?
    @is_onboarding ||= request.request_uri.scan(/^\/welcome\//).present?
  end

  def is_fullscreen_page?
    uri = request.request_uri

    @is_fullscreen_page ||= uri.scan(/^\/welcome\/(intro|history)/).present? || 
                            uri.scan(/^\/purchases\/unapproved/).present?
  end

  # Generate body attributes to display the current theme.
  #
  def theme_body_attributes
    @theme ||= logged_in? ? self.current_user.setting.theme : Theme.default

    unless is_phone_device? || is_fullscreen_page?
      "style=\"background-image:url('#{@theme.background_url}')\" "\
      "class='#{@theme.background_body_class}'"
    else
      ""
    end
  end

  # Test if the header is to be hidden.
  #
  def hide_header?
    @web_view_mode || is_fullscreen_page?
  end

  # test if the footer is to be hidden.
  #
  def hide_footer?
    is_onboarding? || is_fullscreen_page?
  end

  def image_url(path)
    Rails.env.starts_with?("d") ? 
      "http://pleg.getmine.com/images/#{path}" :
      "#{ActionController::Base.asset_host.gsub("%d","")}/images/#{path}"
  end

end
