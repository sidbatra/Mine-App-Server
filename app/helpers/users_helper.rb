module UsersHelper
  
  # Display name for the user
  #
  def user_full_name(user)
    user.first_name + ' ' + user.last_name
  end

  # Public: Gender of the user which defaults
  # to female incase the gender is unavailable.
  #
  # user - The User whose gender string is needed.
  #
  # Returns the gender String
  #
  def user_gender(user)
    user.gender ? user.gender : 'female'
  end

end
