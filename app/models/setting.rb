class Setting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :post_to_timeline, :email_interaction, 
                    :email_influencer, :email_update,
                    :fb_publish_stream, :fb_publish_actions

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :post_to_timeline, :in => [true,false]
  validates_inclusion_of  :email_interaction, :in => [true,false]
  validates_inclusion_of  :email_influencer, :in => [true,false]
  validates_inclusion_of  :email_update, :in => [true,false]
  validates_inclusion_of  :fb_publish_actions, :in => [true,false]
  validates_inclusion_of  :fb_publish_stream, :in => [true,false]
  validates_inclusion_of  :post_to_fb_album, :in => [true,false]


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Whether or not the user has given fb extended permissions.
  # The method uses the value stored in our db instead of FBGraph 
  #
  def fb_extended_permissions
    self.fb_publish_stream
  end

  # Whether or not the user has given fb publish permissions.
  # The method uses the value stored in our db instead of FBGraph 
  #
  def fb_publish_permissions
    self.fb_publish_actions & self.fb_publish_stream
  end

  # Whether or not the user's current settings enable posting
  # photos to facebook album
  #
  def post_to_fb_album?  
    self.fb_publish_stream & self.post_to_fb_album
  end

  # Whether or not the user's current settings enable posting
  # to facebook timeline 
  #
  def post_to_timeline?  
    self.fb_publish_actions & self.post_to_timeline
  end

end
