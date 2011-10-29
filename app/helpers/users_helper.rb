module UsersHelper
  
  # Generate text for a user to share
  #
  def user_share_text(user)
    [user.first_name,
      user.last_name, 
      "shared",
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

  # Display name for category when used in a create link
  #
  def category_create_link_text(category)
    name = category.id == 8 ? 
            category.name.gsub("Other","Anything") :
            category.name

    "Add your #{name} ›" 
  end


  # Display text for category when used in a filter link
  def category_filter_link_text(category,user)
    "#{category.name} " + "(#{user.products_category_count(category.id)})" 
  end


end
