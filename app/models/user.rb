class User < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :products, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :searches, :dependent => :destroy
  has_many :followings
  has_many :followers, :through => :followings
  has_many :inverse_followings, :class_name => "Following", :foreign_key => "follower_id"
  has_many :inverse_followers, :through => :inverse_followings, :source => :user

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
  def self.add(attributes,source)
    user = find_or_initialize_by_email(
            :email        => attributes.email,
            :first_name   => attributes.first_name,
            :last_name    => attributes.last_name,
            :gender       => attributes.gender,
            :birthday     => attributes.birthday,
            :fb_user_id   => attributes.identifier,
            :source       => source)

    user.access_token = attributes.access_token.to_s
    user.save!
    user
  end

  # Find user by the token stored in their cookie
  #
  def self.find_by_cookie(token)
    find_by_remember_token(token)
  end

  # Fetch all users who have commented on the given product
  #
  def self.commented_on_product(product_id)
    all(
      :conditions => {:comments => {:product_id => product_id}},
      :joins      => :comments,
      :group      => "users.id")
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Edit attributes of the model
  #
  def edit(attributes)
    
    if attributes[:byline].present?
      self.byline = attributes[:byline]
    end

    self.save
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

  # User age
  #
  def age
    dob = self.birthday.utc 
    now = Time.now.utc.to_date
    now.year - dob.year - 
    ((now.month > dob.month || 
                  (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    super(options.merge(:only => [:id,:byline]))
  end

end
