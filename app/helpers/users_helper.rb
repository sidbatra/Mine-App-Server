module UsersHelper
  
  # Generate text for a user to share
  #
  def user_share_text(user)
    [user.first_name,
      user.last_name, 
      "shared",
      user.gender == "male" ? "his" : "her"].join(' ')
  end
end
