# Presenter for the User mode
#
class UserPresenter < BasePresenter
  presents :user

  # Display name for the user's closet
  #
  def closet_name
    user.first_name + "'s closet"
  end

  # Full url of the user's closet
  #
  def closet_url(src)
    h.user_url(user,:src => src)
  end

  # Image representing the closet - image of
  # last product uploaded
  #
  def closet_image(products)
    products.present? ? products.first.thumbnail_url : ''
  end

  # Message displaying people you're following
  #
  def following_message
    message = ""

    if user.ifollowers.present?
      message = h.is_current_user(user.id) ? 
                  "People you're following" : 
                  user.first_name + " is following"
    else
      message = h.is_current_user(user.id) ?
                  "You aren't following anyone yet." :
                  user.first_name + " isn't following anyone yet."
    end

    message
  end

  # Description message for the user's use of
  # the app. 
  #
  def usage_description
    user.first_name + " is using Felvy to share what " +
    (user.is_male? ? "he" : "share") +
    " buys and owns. Its fun, and free!"
  end


end
