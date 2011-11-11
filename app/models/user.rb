class User < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :products, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :searches, :dependent => :destroy

  has_many :followings, :dependent  => :destroy
  has_many :followers,  :through    => :followings
  has_many :inverse_followings, :class_name   => "Following", 
                                :foreign_key  => "follower_id",
                                :dependent    => :destroy

  has_many :ifollowers, :through => :inverse_followings, :source => :user

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :first_name
  validates_presence_of   :last_name
  validates_presence_of   :email

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

  # Return json options specifiying which attributes and methods
  # to pass in the json when the model is used within an include
  # of another model's json
  #
  def self.json_options
    options             = {}
    options[:only]      = [:id,:first_name,:last_name]
    options[:methods]   = [:photo_url]

    [self.name.downcase.to_sym,options]
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Edit attributes of the model
  #
  def edit(attributes)
    
    if !attributes[:byline].nil?
      self.byline = attributes[:byline]
    end

    self.save
  end

  # Updates custom counter cache columns when
  # a product is added by the user
  #
  def add_product_worth(price,category_id)
    category_field = "products_#{category_id}_count"

    self.update_attributes(
      :products_count => self.products_count + 1,
      :products_price => self.products_price + price,
      category_field  => self[category_field] + 1)
  end

  # Updates custom counter cache columns when
  # a product is removed by the user
  #
  def remove_product_worth(price,category_id)
    category_field = "products_#{category_id}_count"

    updates = {}
    updates[:products_count]  = self.products_count - 1
    updates[:products_price]  = self.products_price - price if price
    updates[category_field]   = self[category_field] - 1 if category_id

    self.update_attributes(updates)
  end

  # Return product count for the given category
  #
  def products_category_count(category_id)
    self["products_#{category_id}_count"]
  end

  # URL for the user photo
  #
  def image_url
    "http://graph.facebook.com/" + fb_user_id + "/picture?type=square" 
  end

  # Alias for image_url
  #
  def photo_url
    image_url
  end

  # Tests gender to see if user is male
  #
  def is_male?
    gender == "male"
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
    if birthday.present?
      dob = self.birthday.utc 
      now = Time.now.utc.to_date
      now.year - dob.year - 
      ((now.month > dob.month || 
                    (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    else
      0
    end
  end

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    super(options.merge(:only => [:id,:byline]))
  end

end
