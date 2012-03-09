class Invite < ActiveRecord::Base
  
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user
  belongs_to :style

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :recipient_id
  validates_inclusion_of  :platform, :in => InvitePlatform.values
  validates_presence_of   :recipient_name
  validates_presence_of   :style_id

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :user_id,:recipient_id,:platform,:recipient_name,:style_id

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Add a new invite 
  #
  def self.add(attributes)
    find_or_create_by_user_id_and_recipient_id(attributes)
  end

end
