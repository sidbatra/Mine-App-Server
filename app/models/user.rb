class User < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_many :purchases, :dependent => :destroy
  has_many :searches, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
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

  #----------------------------------------------------------------------
  # Indexing
  #----------------------------------------------------------------------
  searchable do
    text :first_name, :as => :first_name_textp, :boost => 3
    text :last_name, :as => :last_name_textp, :boost => 2
    text :email
    integer :followers, :multiple => true do 
      followings.select{|f| f.is_active}.map(&:follower_id)
    end
  end

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :purchases_count, lambda {|count| {
                  :conditions => {:purchases_count => count}}}
  named_scope :purchases_count_gt, lambda {|count| {
                  :conditions => {:purchases_count_gt => count}}}
  named_scope :by_updated_at, {:order => 'updated_at DESC'}
  named_scope :by_visited_at, {:order => 'visited_at DESC'}

  named_scope :visited, lambda{|time| {
                          :conditions => {:visited_at_gt => time}}}

  named_scope :with_stores, :include => {:shoppings => :store}
  named_scope :with_setting, :include => :setting
  named_scope :with_purchases, :include => :purchases
  named_scope :with_ifollowers, :include => :ifollowers
  named_scope :with_followings, :include => :followings

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :fb_user_id,:source,:email,:gender,:birthday,
                    :first_name,:last_name,:access_token,:byline,
                    :tumblr_access_token, :tumblr_access_token_secret,
                    :tw_access_token, :tw_access_token_secret,
                    :iphone_device_token

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Find user by the token stored in their cookie.
  #
  def self.find_by_cookie(token)
    find_by_remember_token(token)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Updated the visited_at datetime to the current time.
  #
  def visited
    self.visited_at = Time.now
    self.save!
  end

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
    "http://graph.facebook.com/#{fb_user_id}/picture?type=#{type}" 
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

  # Full name of the user
  #
  def full_name
    self.first_name + ' ' + self.last_name
  end

  # Test if the remember_token for the user cookie has expired.
  #
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # Save a remember_token and its expiry representing the cookie.
  #
  def remember
    self.remember_token_expires_at  = 1.weeks.from_now.utc
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

  # Make the access token nil on expiry or when the publish
  # permissions are removed
  #
  def fb_access_token_expired
    self.access_token = nil
    save!
  end

  # Whether or not we have a valid and non expired access token 
  # for facebook. If not update the database 
  #
  def fb_access_token_valid?
    if self.access_token.present? 
      begin
        valid = self.fb_permissions.include?(:publish_actions)
        self.fb_access_token_expired unless valid

        valid
      rescue FbGraph::InvalidToken => ex
        self.fb_access_token_expired
        false
      end
    else 
      false
    end
  end

  # Whether or not the user has authorized our facebook application
  #
  def fb_authorized?
    self.access_token.present? 
  end

  # Whether or not the user has authorized our twitter application
  # and in turn given us read/write permissions
  #
  def tw_authorized?
    self.tw_access_token.present? & self.tw_access_token_secret.present?
  end

  # Whether or not the user has authorized our tumblr application
  # and in turn given us read/write permissions
  #
  def tumblr_authorized?
    self.tumblr_access_token.present? & self.tumblr_access_token_secret.present?
  end

  # Obfuscated id for the user
  #
  def obfuscated_id
    Cryptography.obfuscate(self.id)
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
