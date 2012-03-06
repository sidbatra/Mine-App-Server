module WelcomeHelper

  # Apply an active class on the currently highlighted
  # step during onboarding.
  #
  # filter String representing step to be tested
  #
  # String active class or empty string
  #
  def apply_active_class(filter)
    @filter == filter ? 'active' : ''
  end
end
