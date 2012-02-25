class User < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_many :products,     :dependent => :destroy
  has_many :comments,     :dependent => :destroy
  has_many :actions,      :dependent => :destroy
  has_many :searches,     :dependent => :destroy
  has_many :contacts,     :dependent => :destroy
  has_many :invites,      :dependent => :destroy
  has_many :collections,  :dependent => :destroy
  has_many :achievements, :dependent => :destroy
  has_many :shoppings,    :dependent => :destroy
  has_many :stores,       :through   => :shoppings
  has_one  :setting,      :dependent => :destroy 

  has_many :followings, :dependent  => :destroy
  has_many :followers,  :through    => :followings,
                        :source     => :follower, 
                        :conditions => 'is_active = 1',
                        :order      => 'followings.created_at DESC'

  has_many :inverse_followings, :class_name   => "Following", 
                                :foreign_key  => "follower_id",
                                :dependent    => :destroy

  has_many :ifollowers, :through    => :inverse_followings, 
                        :source     => :user, 
                        :conditions => 'is_active = 1',
                        :order      => 'followings.created_at DESC'

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :first_name
  validates_presence_of   :last_name
  validates_presence_of   :email

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :products_count, lambda {|count| {
                  :conditions => {:products_count => count}}}
  named_scope :followings_count, lambda {|count| {
                  :conditions => {:followings_count => count}}}
  named_scope :collections_count_gt, lambda {|count| {
                  :conditions => {:collections_count_gt => count}}}
  named_scope :products_count_gt, lambda {|count| {
                  :conditions => {:products_count_gt => count}}}
  named_scope :followings_count_gt, lambda {|count| {
                  :conditions => {:followings_count_gt => count}}}
  named_scope :stars, 
                  :joins      => :products, 
                  :conditions => {
                    :products           => {:created_at => 1.day.ago..Time.now},
                    :products_count_gt  => 9,
                    :gender_ne          => 'male'},
                  :group      => "users.id", 
                  :order      => "count(users.id) DESC, users.created_at DESC"

  named_scope :top_shoppers, lambda {|store_id| {
                :select       => "users.*,count(users.id) as products_at_store",
                :joins        => :products,
                :conditions   => {
                  :products_count_gt => 9,
                  :products   => {
                      :store_id   => store_id,
                      :created_at => 30.days.ago..Time.now},
                  :gender_ne  => 'male'},
                :group        => "users.id HAVING products_at_store > 1", 
                :order        => "products_at_store DESC,users.id"}}

  named_scope :with_stores, :include => {:shoppings => :store}
  named_scope :with_collections_with_products,  
                :include => {:collections => :products} 
  named_scope :with_setting, :include => :setting

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :mine_contacts
  attr_accessible :fb_user_id,:source,:email,:gender,:birthday,
                    :first_name,:last_name,:access_token,:byline

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

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

    user.build_setting if user.new_record?
      
    user.save!
    user
  end

  # Find user by the token stored in their cookie
  #
  def self.find_by_cookie(token)
    find_by_remember_token(token)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Return product count for the given category
  #
  def products_category_count(category_id)
    Cache.fetch(KEYS[:user_category_count] % [self.id,category_id]) do
      Product.for_user(self.id).in_category(category_id).count 
    end
  end

  # Test is the user was created very recently
  #
  def is_fresh
    (Time.now - self.created_at) < 60
  end

  # URL for the user photo
  #
  def image_url(type='square')
    "http://graph.facebook.com/" + fb_user_id + "/picture?type=#{type}" 
  end

  # Alias for image_url
  #
  def photo_url
    image_url
  end

  # Alias for large image url
  #
  def large_photo_url
    image_url('large')
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

  # List of facebook friends
  #
  def fb_friends
    fb_user = FbGraph::User.new('me', :access_token => self.access_token)
    fb_user.friends
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
