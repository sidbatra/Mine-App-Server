class User < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :products, :dependent => :destroy

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :first_name
  validates_presence_of   :last_name
  validates_presence_of   :email
  validates_presence_of   :birthday

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new user or find an existing one based on email
  #
  def self.add(attributes,campaign)
    user = find_or_initialize_by_email(
            :email        => attributes.email,
            :first_name   => attributes.first_name,
            :last_name    => attributes.last_name,
            :gender       => attributes.gender,
            :birthday     => attributes.birthday,
            :fb_user_id   => attributes.identifier,
            :campaign     => campaign)

    user.access_token = attributes.access_token.to_s
    user.save!
    user
  end

  # Find user by the token stored in their cookie
  #
  def self.find_by_cookie(token)
    find_by_remember_token(token)
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Share the given product to FB
  #
  def share_product(product,product_url)
    fb_user = FbGraph::User.me(access_token)
    fb_user.feed!(
      :message      => product.endorsement,
      :picture      => product.photo_url,
      :link         => product_url,
      :description  => "#{self.first_name} is using Felvy to share the "\
                        "things #{self.gender == "male" ? "he" : "she"} "\
                        "owns with the world. It's free!",
      :name         => product.title)
  end

  # URL for the user photo
  #
  def image_url
    fb_user_id != "" ? 
      "http://graph.facebook.com/" + fb_user_id + "/picture?type=square" :
      FileSystem.url(access_token)
  end

  # Alias for image_url
  #
  def photo_url
    image_url
  end

  # Test if the remember_token for the user cookie has expired
  #
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # Save a remember_token and its expiry representing the cookie
  #
  def remember
    self.remember_token_expires_at  = 4.weeks.from_now.utc
    self.remember_token             = Cryptography.encrypt_with_salt(
                                        SecureRandom.hex(10),
                                        remember_token_expires_at)
    save(false)
  end

  # Clear cookie information
  #
  def forget
    self.remember_token_expires_at  = nil
    self.remember_token             = nil

    save(false)
  end

end
