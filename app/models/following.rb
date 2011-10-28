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
    create(
      :user_id      => user_id,
      :follower_id  => follower_id)
  end

end
