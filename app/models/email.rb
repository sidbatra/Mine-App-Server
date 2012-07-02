class Email < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :emailable, :polymorphic => true

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :recipient_id
  validates_presence_of   :sender_id
  validates_presence_of   :emailable_id
  validates_inclusion_of  :emailable_type, :in => %w(User Store Following Comment Like)
  validates_presence_of   :message_id
  validates_presence_of   :request_id
  validates_inclusion_of  :purpose, :in => EmailPurpose.values

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :for, lambda{|purpose| {:conditions => {
                                      :purpose => purpose}}}

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :recipient_id, :sender_id, :emailable_id, :emailable_type, 
                    :purpose, :message_id, :request_id

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method for creating a new email.
  #
  def self.add(attributes,message_id,request_id)
    attributes[:message_id] = message_id
    attributes[:request_id] = request_id

    create!(attributes)
  end

end
