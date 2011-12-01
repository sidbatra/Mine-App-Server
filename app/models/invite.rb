class Invite < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user

  #-----------------------------------------------------------------------------
  # Class Methods 
  #-----------------------------------------------------------------------------

  # Add a new invite 
  #
  def self.add(user_id,recipient_id)
    find_or_create_by_user_id_and_recipient_id(
      :user_id        => user_id,
      :recipient_id   => recipient_id)
  end

end
