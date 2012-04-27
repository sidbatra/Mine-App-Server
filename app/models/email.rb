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
  validates_inclusion_of  :emailable_type, :in => %w(User Store Following)
  validates_presence_of   :message_id
  validates_presence_of   :request_id
  validates_inclusion_of  :purpose, :in => EmailPurpose.values

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
