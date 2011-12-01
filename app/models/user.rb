class User < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Mixins
  #-----------------------------------------------------------------------------
  include DW::Handler

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :products, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :searches, :dependent => :destroy
  has_many :contacts, :dependent => :destroy

  has_many :followings, :dependent  => :destroy
  has_many :followers,  :through    => :followings
  has_many :inverse_followings, :class_name   => "Following", 
                                :foreign_key  => "follower_id",
                                :dependent    => :destroy

  has_many :ifollowers, :through => :inverse_followings, 
              :source => :user, :conditions => 'is_active = 1'


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
    user = find_or_initialize_by_fb_user_id(
            :fb_user_id   => attributes.identifier,
            :source       => source)

    user.email        = attributes.email
    user.gender       = attributes.gender
    user.birthday     = attributes.birthday
    user.first_name   = attributes.first_name
    user.last_name    = attributes.last_name
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

  # Fetch all the star users
  #
  def self.stars 
    Cache.fetch(KEYS[:star_users]) do
        all(
          :joins      => :products,
          :conditions => {:products => {:created_at => 2.days.ago..Time.now}},
          :group      => "users.id", 
          :order      => "count(users.id) DESC, users.id",
          :limit      => 20)
    end
  end

  # Fetch all top shoppers for a store
  #
  def self.top_shoppers(store_id)
    Cache.fetch(KEYS[:store_top_shoppers] % store_id) do
        all(
          :joins      => :products,
          :conditions => {:products => {
                            :store_id   => store_id,
                            :created_at => 20.days.ago..Time.now}},
          :group      => "users.id", 
          :order      => "count(users.id) DESC, users.id",
          :limit      => 20)
    end
  end

  # Return json options specifiying which attributes and methods
  # to pass in the json when the model is used within an include
  # of another model's json
  #
  def self.json_options(options={})
    options[:only]      = [:id,:first_name,:last_name,:handle]
    options[:methods]   = [:photo_url] if options[:methods].nil?

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

  # Return product count for the given category
  #
  def products_category_count(category_id)
    Cache.fetch(KEYS[:user_category_count] % [self.id,category_id]) do
      Product.for_user(self.id).in_category(category_id).count 
    end
  end

  # Total price of all the products
  #
  def products_price
    Cache.fetch(KEYS[:user_price] % self.id) do
      Product.for_user(self.id).sum(:price) 
    end
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
    options[:only]      = [] if options[:only].nil?
    options[:only]     += [:id,:first_name,:last_name,:handle]

    options[:methods]   = [] if options[:methods].nil?
    options[:methods]  += [:photo_url]

    super(options)
  end

  
  protected

  # Required by Handler mixin to create base handle
  #
  def handle_base
    first_name + ' ' + last_name
  end

  # Required by Handler mixin to test uniqueness of handle
  #
  def handle_uniqueness_query(handle)
    self.class.find_by_handle(handle)
  end

end
