class Setting < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme
  attr_accessible :email_influencer, :email_update, :email_follower,
                    :email_digest, :email_importer, :share_to_facebook,
                    :share_to_twitter, :share_to_tumblr,:theme_id

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :email_influencer, :in => [true,false]
  validates_inclusion_of  :email_update, :in => [true,false]
  validates_inclusion_of  :email_digest, :in => [true,false]
  validates_inclusion_of  :email_follower, :in => [true,false]
  validates_inclusion_of  :share_to_facebook, :in => [true,false]
  validates_inclusion_of  :share_to_twitter, :in => [true,false]
  validates_inclusion_of  :share_to_tumblr, :in => [true,false]


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------


  # Whether or not the user has accepted facebook authorization
  #
  def fb_auth
    self.user.fb_authorized?
  end

  # Whether or not the user has accepted twitter authorization
  #
  def tw_auth
    self.user.tw_authorized?
  end

  # Whether or not the user has accepted tumblr authorization
  #
  def tumblr_auth
    self.user.tumblr_authorized?
  end

  # Whether or not the user's current settings enable posting
  # to facebook timeline 
  #
  def post_to_facebook?  
    self.share_to_facebook & self.fb_auth
  end

  # Whether or not the user's current settings enable posting 
  # to twitter
  #
  def post_to_twitter?  
    self.share_to_twitter & self.tw_auth
  end

  # Whether or not the user's current settings enable posting 
  # to tumblr 
  #
  def post_to_tumblr?  
    self.share_to_tumblr & self.tumblr_auth
  end

  # Unsubscribe from all email types.
  #
  def unsubscribe
    self.email_influencer = false
    self.email_update = false
    self.email_digest = false
    self.email_follower = false
    self.email_importer = false
    save!
  end

end
