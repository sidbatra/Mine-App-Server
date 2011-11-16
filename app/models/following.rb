class Following < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :follower, :class_name => "User"

  #-----------------------------------------------------------------------------
  # Class Methods 
  #-----------------------------------------------------------------------------

  # Add a new following
  #
  def self.add(user_id,follower_id)
    following = find_or_create_by_user_id_and_follower_id(
                  :user_id      => user_id,
                  :follower_id  => follower_id)

    unless following.is_active
      following.is_active = true
      following.save!
    end

    following
  end
  
  #-----------------------------------------------------------------------------
  # Instance Methods 
  #-----------------------------------------------------------------------------

  # Disable an existing following
  #
  def remove
    self.is_active = false
    self.save!
  end

end
