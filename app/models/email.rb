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
  validates_inclusion_of  :emailable_type, :in => %w(User Store Following Comment Action Collection)
  validates_presence_of   :message_id
  validates_presence_of   :request_id
  validates_inclusion_of  :purpose, :in => EmailPurpose.values

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new email 
  #
  def self.add(attributes,message_id,request_id)
    create!(
      :recipient_id     => attributes[:recipient_id],
      :sender_id        => attributes[:sender_id],
      :emailable_id     => attributes[:emailable_id],
      :emailable_type   => attributes[:emailable_type],
      :purpose          => attributes[:purpose],
      :message_id       => message_id,
      :request_id       => request_id)
  end

end
