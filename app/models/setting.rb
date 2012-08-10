class Setting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :email_influencer, :email_update,
                    :fb_publish_stream, :fb_publish_actions,
                    :share_to_facebook,
                    :share_to_twitter, :share_to_tumblr

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :email_influencer, :in => [true,false]
  validates_inclusion_of  :email_update, :in => [true,false]
  validates_inclusion_of  :fb_publish_actions, :in => [true,false]
  validates_inclusion_of  :fb_publish_stream, :in => [true,false]
  validates_inclusion_of  :share_to_facebook, :in => [true,false]
  validates_inclusion_of  :share_to_twitter, :in => [true,false]
  validates_inclusion_of  :share_to_tumblr, :in => [true,false]


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Whether or not the user has given fb extended permissions.
  # The method uses the value stored in our db instead of FBGraph 
  #
  def fb_extended_permissions
    self.fb_publish_stream
  end
  
  # Disable fb permissions, primarily used as a raction
  # to expired tokens.
  #
  def revoke_fb_permissions
    self.fb_publish_actions = false
    self.fb_publish_stream  = false
    save!
  end

  # Whether or not the user has given fb publish permissions.
  # The method uses the value stored in our db instead of FBGraph 
  #
  def fb_publish_permissions
    self.fb_publish_actions
  end

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
    self.fb_publish_actions & self.share_to_facebook & self.fb_auth
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

end
