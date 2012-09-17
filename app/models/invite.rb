class Invite < ActiveRecord::Base
  
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :recipient_id
  validates_inclusion_of  :platform, :in => InvitePlatform.values

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :user_id,:recipient_id,:platform,:recipient_name,:message

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user,  :include => :user
  named_scope :by_id,      :order => 'id DESC'

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Facetory method for creating an invite.
  #
  def self.add(attributes,user_id)
    create!(
        :user_id        => user_id,
        :recipient_id   => attributes[:recipient_id],
        :platform       => attributes[:platform],
        :recipient_name => attributes[:recipient_name],
        :message        => attributes[:message])
  end

end
