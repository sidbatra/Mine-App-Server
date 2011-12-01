class Contact < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user

  #-----------------------------------------------------------------------------
  # Class Methods 
  #-----------------------------------------------------------------------------

  # Add a new contact 
  #
  def self.add(user_id,third_party_id)
    create!(
      :user_id          => user_id,
      :third_party_id   => third_party_id)
  end

end
