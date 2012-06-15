class Setting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :post_to_timeline, 
                    :email_influencer, :email_update,
                    :fb_publish_stream, :fb_publish_actions,
                    :share_to_twitter

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :post_to_timeline, :in => [true,false]
  validates_inclusion_of  :email_influencer, :in => [true,false]
  validates_inclusion_of  :email_update, :in => [true,false]
  validates_inclusion_of  :fb_publish_actions, :in => [true,false]
  validates_inclusion_of  :fb_publish_stream, :in => [true,false]
  validates_inclusion_of  :share_to_twitter, :in => [true,false]


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
    save!
  end

  # Whether or not the user has given fb publish permissions.
  # The method uses the value stored in our db instead of FBGraph 
  #
  def fb_publish_permissions
    self.fb_publish_actions
  end

  def tw_permissions
    self.user.tw_permissions?
  end

  # Whether or not the user's current settings enable posting
  # to facebook timeline 
  #
  def post_to_timeline?  
    self.fb_publish_actions & self.post_to_timeline
  end

  # Whether or not the user's current settings enable posting 
  # to twitter
  #
  def post_to_twitter?  
    self.share_to_twitter & self.tw_permissions
  end

end
