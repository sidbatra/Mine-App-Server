class User < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :style
  has_many :products,       :dependent => :destroy
  has_many :comments,       :dependent => :destroy
  has_many :actions,        :dependent => :destroy
  has_many :searches,       :dependent => :destroy
  has_many :contacts,       :dependent => :destroy
  has_many :collections,    :dependent => :destroy
  has_many :achievements,   :dependent => :destroy
  has_many :shoppings,      :dependent => :destroy
  has_many :stores,         :through   => :shoppings
  has_one  :setting,        :dependent => :destroy 
  has_many :ticker_actions, :dependent => :destroy

  has_many :followings, :dependent  => :destroy
  has_many :followers,  :through    => :followings,
                        :source     => :follower, 
                        :conditions => 'is_active = 1'

  has_many :inverse_followings, :class_name   => "Following", 
                                :foreign_key  => "follower_id",
                                :dependent    => :destroy

  has_many :ifollowers, :through    => :inverse_followings, 
                        :source     => :user, 
                        :conditions => 'is_active = 1'

  has_many :invites,      :dependent => :destroy
  has_many :received_invites, :class_name   => "Invite",
                              :foreign_key  => "recipient_id",
                              :primary_key  => "fb_user_id",
                              :dependent => :destroy

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :first_name
  validates_presence_of   :last_name
  validates_presence_of   :fb_user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :products_count, lambda {|count| {
                  :conditions => {:products_count => count}}}
  named_scope :followings_count, lambda {|count| {
                  :conditions => {:followings_count => count}}}
  named_scope :shoppings_count, lambda {|count| {
                  :conditions => {:shoppings_count => count}}}
  named_scope :collections_count, lambda {|count| {
                  :conditions => {:collections_count => count}}}
  named_scope :products_count_gt, lambda {|count| {
                  :conditions => {:products_count_gt => count}}}
  named_scope :followings_count_gt, lambda {|count| {
                  :conditions => {:followings_count_gt => count}}}
  named_scope :shoppings_count_gt, lambda {|count| {
                  :conditions => {:shoppings_count_gt => count}}}
  named_scope :collections_count_gt, lambda {|count| {
                  :conditions => {:collections_count_gt => count}}}
  named_scope :by_products_count, {:order => 'products_count DESC'}
  named_scope :by_updated_at, {:order => 'updated_at DESC'}
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
  named_scope :with_ifollowers, :include => :ifollowers
  named_scope :created_collection_in, lambda {|range| {
                :joins      => :collections,
                :conditions => {:collections => {:created_at => range}}}} 

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :fb_user_id,:source,:email,:gender,:birthday,
                    :first_name,:last_name,:access_token,:byline,
                    :style_id

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new user or find an existing one based on email
  #
  def self.add_from_fb(attributes,source)
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

  # Add a new user when an existing user invites a friend
  #
  def self.add_from_invite(attributes)
    find_or_create_by_fb_user_id(attributes)
  end

  # Find user by the token stored in their cookie
  #
  def self.find_by_cookie(token)
    find_by_remember_token(token)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Whether the user has actually registered or is a stub user from
  # an invite
  #
  def is_registered?
    access_token.present?
  end

  # Test is the user was created very recently
  #
  def is_fresh
    (Time.now - self.created_at) < 60
  end

  # URL for the user's image on fb of the given type
  #
  def fb_image_url(type='square')
    "http://graph.facebook.com/" + fb_user_id + "/picture?type=#{type}" 
  end

  # Relative path to the square image
  #
  def square_image_path
    's_' + image_path
  end

  # Absolute url of the square thumbnail
  #
  def square_image_url
    are_images_hosted ?
      FileSystem.url(square_image_path) :
      fb_image_url('square')
  end

  # Old method for fetching square fb user image
  #
  def photo_url
    fb_image_url('square')
  end
 # alias :photo_url :square_image_url

  # Absolute url of the large image
  #
  def image_url
    are_images_hosted ?
      FileSystem.url(image_path) :
      fb_image_url('large')
  end

  # Old method for fetching large fb user image
  #
  def large_photo_url
    fb_image_url('large')
  end
  #alias :large_photo_url :image_url

  # Tests gender to see if user is male
  #
  # returns. Boolean. true is user is male.
  #
  def is_male?
    gender && gender.first == 'm'
  end

  # Tests gender to see if user is female
  #
  # returns. Boolean. true is user is female.
  #
  def is_female?
    gender && gender.first == 'f'
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

  # List of facebook permissions
  #
  def fb_permissions
    fb_user = FbGraph::User.new('me', :access_token => self.access_token)
    fb_user.permissions
  end

  # Host user's fb image
  #
  def host
    return unless fb_user_id.present?

    # Set to false to retrieve latest fb image
    self.are_images_hosted = false

    self.image_path  = Base64.encode64(
                           SecureRandom.hex(10) + 
                           Time.now.to_i.to_s).chomp + ".jpg"

    image = MiniMagick::Image.open(image_url)

    FileSystem.store(
      image_path,
      open(image.path),
      "Content-Type"  => "image/jpeg",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))


    image = MiniMagick::Image.open(square_image_url)

    FileSystem.store(
      square_image_path,
      open(image.path),
      "Content-Type"  => "image/jpeg",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))

    self.are_images_hosted = true
    save!

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
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
