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

  # Placeholders for welcome/share conditional on the
  # given user's gender.
  #
  # user - User. User model for the user who'll see the placeholders.
  #
  # returns - Array. Image paths relative to the 
  #            placeholders/welcome_share folder.
  #
  def share_placeholders(user)
    placeholders = []

    if user.is_male?
      placeholders = ['male1.jpg','male2.jpg',
                      'male3.jpg','male4.jpg']
    else
      placeholders = ['female1.jpg','female2.jpg',
                      'female3.jpg','female4.jpg']
    end

    placeholders
  end
end
