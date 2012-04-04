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

  # Link to larger user photo
  #
  def large_picture(src)
    h.link_to h.image_tag(
                user.large_image_url, 
                :class  => '',
                :alt    => self.full_name),
              closet_path(src)
  end

  # Link to small square user photo
  #
  def small_picture(src)
    h.link_to h.image_tag(
                user.square_image_url, 
                :class  => "",
                :alt    => ''),
              closet_path(src)
  end

  # Display name for the user's closet
  #
  def closet_name
    user.first_name + "'s OnCloset"
  end

  # Full title of the closet
  #
  def closet_title(casual=false)
    name  = casual ? self.first_name : self.full_name

    if name.length >= 20
      parts = name.split(/ |-/)
      name  = parts.first + ' ' + parts.last if parts.length > 2
    end

    name + "'s Closet"
  end

  # Full url of the user's closet
  #
  def closet_url(src)
    h.user_url(user.handle,:src => src)
  end

  # Relative path of the user's closet
  #
  def closet_path(src,anchor=nil)
    h.user_path(user.handle,:src => src,:anchor => anchor)
  end

  # Image representing the closet - image of
  # last product uploaded
  #
  def closet_image(products)
    products.present? ? products.first.thumbnail_url : ''
  end

  # Description message for the user's use of 
  # the app. 
  #
  def usage_description
    user.first_name + " is using #{CONFIG[:name]}: " +
    "an online closet for your latest purchases and daily style."
  end

  # Unique identifier to be used a source
  #
  def source_id
    "user_" + user.id.to_s
  end


end
