module UsersHelper
  
  # Display name for the user
  #
  def user_full_name(user)
    user.first_name + ' ' + user.last_name
  end

  # Public. Geneder specific pronoun for the user.
  #
  # user - The User for which the pronoun is needed.
  #
  # Returns the String gender pronoun - his or her.
  def user_pronoun(user)
    user.is_male? ? 'his' : 'her'
  end

  # Public. Geneder specific singular pronoun for the user.
  #
  # user - The User for which the pronoun is needed.
  #
  # Returns the String gender singular pronoun - he or she.
  def user_singular_pronoun(user)
    user.is_male? ? 'he' : 'she'
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
