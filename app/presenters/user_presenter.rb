# Presenter for the User model
#
class UserPresenter < BasePresenter
  presents :user
  delegate :first_name,:full_name, :to => :user

  # He / she
  #
  def pronoun
    user.is_male? ? 'he' : 'she'
  end

  # His / her
  #
  def possessive_pronoun
    user.is_male? ? 'his' : 'her'
  end

  # Him / her
  #
  def personal_pronoun
    user.is_male? ? 'him' : 'her'
  end

end
