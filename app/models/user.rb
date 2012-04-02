class User < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_many :products, :dependent => :destroy
  has_many :searches, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :shoppings, :dependent => :destroy
  has_many :stores, :through   => :shoppings
  has_one  :setting, :dependent => :destroy 
  has_many :followings, :dependent  => :destroy
  has_many :followers, :through    => :followings,
                        :source     => :follower, 
                        :conditions => 'is_active = 1',
                        :order => "followings.created_at DESC"
  has_many :inverse_followings, :class_name   => "Following", 
                                :foreign_key  => "follower_id",
                                :dependent    => :destroy
  has_many :ifollowers, :through    => :inverse_followings, 
                        :source     => :user, 
                        :conditions => 'is_active = 1',
                        :order => "followings.created_at DESC"
  has_many :invites, :dependent => :destroy
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
  named_scope :products_count_gt, lambda {|count| {
                  :conditions => {:products_count_gt => count}}}
  named_scope :followings_count_gt, lambda {|count| {
                  :conditions => {:followings_count_gt => count}}}
  named_scope :by_updated_at, {:order => 'updated_at DESC'}

  named_scope :with_stores, :include => {:shoppings => :store}
  named_scope :with_setting, :include => :setting
  named_scope :with_ifollowers, :include => :ifollowers

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :fb_user_id,:source,:email,:gender,:birthday,
                    :first_name,:last_name,:access_token,:byline

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method to create a new user or update important fields
  # of an existing user.
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

  # Factory method to create a user via an invite.
  #
  def self.add_from_invite(attributes)
    find_or_create_by_fb_user_id(attributes)
  end

  # Find user by the token stored in their cookie.
  #
  def self.find_by_cookie(token)
    find_by_remember_token(token)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Whether the user has actually registered or is a stub user from
  # an invite.
  #
  # returns - Boolean. true if the user is registered false otherwise.
  #
  def is_registered?
    access_token.present?
  end

  # Test is the user was created very recently.
  #
  def is_fresh
    (Time.now - self.created_at) < 60
  end

  # URL for the user's image on fb.
  #
  # type - String:'square'. Type of fb image - square | small | normal | large
  #
  # returns - String. Url of the image.
  #
  def fb_image_url(type='square')
    "http://graph.facebook.com/" + fb_user_id + "/picture?type=#{type}" 
  end

  # Convienience method to get the user's square fb image.
  #
  def square_image_url
    fb_image_url('square')
  end

  # Convienience method to get the user's large fb image.
  #
  def large_image_url
    fb_image_url('large')
  end

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

  # Test if the remember_token for the user cookie has expired.
  #
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # Save a remember_token and its expiry representing the cookie.
  #
  def remember
    self.remember_token_expires_at  = 4.weeks.from_now.utc
    self.remember_token             = Cryptography.encrypt_with_salt(
                                        SecureRandom.hex(10),
                                        remember_token_expires_at)
    save(false)
  end

  # Clear cookie information.
  #
  def forget
    self.remember_token_expires_at  = nil
    self.remember_token             = nil

    save(false)
  end

  # Calculate the user's age from their birthday.
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

  # List of facebook friends loaded via the open graph.
  #
  def fb_friends
    fb_user = FbGraph::User.new('me', :access_token => self.access_token)
    fb_user.friends
  end

  # List of facebook permissions loaded via the open graph.
  #
  def fb_permissions
    fb_user = FbGraph::User.new('me', :access_token => self.access_token)
    fb_user.permissions
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
