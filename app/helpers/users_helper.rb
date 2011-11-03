module UsersHelper
  
  # Generate text for a user to share
  #
  def user_share_text(user)
    [user.first_name,
      user.last_name, 
      "bought",
      user.gender == "male" ? "his" : "her"].join(' ')
  end
  
  # Display name for the user
  #
  def user_full_name(user)
    user.first_name + " " + user.last_name
  end
  
  # Pronoun for the given user
  #
  def user_pronoun(user)
  	user.gender == "male" ? "he" : "she"
  end
  
  # Possessive pronoun for the given user
  #
  def user_pronoun_possesive(user)
	user.gender == "male" ? "his" : "her"
  end

end
