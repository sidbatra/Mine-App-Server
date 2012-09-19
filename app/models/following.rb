class Following < ActiveRecord::Base
  
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user, :touch => true
  belongs_to :follower, :touch => true, :class_name => "User"

  #----------------------------------------------------------------------
  # Validations 
  #----------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :follower_id
  validates_inclusion_of  :source, :in => FollowingSource.values

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :send_email, :is_active_toggled
  attr_accessible :follower_id, :user_id, :send_email, :source

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :active, :conditions => {:is_active => true}

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Factory method for adding a following. If the following already
  # exists it's status is made active again.
  #
  # user_id - Integer. User id who's being followed.
  # follower_id - Integer. User id who's following.
  # source - FollowingSource:Manual. Source of creation.
  # send_email - Boolean:true. Notify user_id via email.
  #
  # returns - Following. The created or updated following.
  #
  def self.add(
        user_id,
        follower_id,
        source = FollowingSource::Manual,
        send_email = true,
        reset = true)

    following = nil

    if follower_id != user_id
      following = find_or_initialize_by_user_id_and_follower_id(
                    :user_id      => user_id,
                    :follower_id  => follower_id,
                    :source       => source,
                    :send_email   => send_email)
      following.is_active = true if following.new_record? || reset
      following.save! if following.changed?
    end

    following
  end

  # Find a following where follower_id is following user_id.
  #
  # returns - Following. Following object is found nil otherwise.
  #
  def self.fetch(user_id,follower_id)
    find_by_user_id_and_follower_id(user_id,follower_id)
  end

  
  #----------------------------------------------------------------------
  # Instance Methods 
  #----------------------------------------------------------------------

  # Disable an existing following.
  #
  def remove
    self.is_active = false
    self.save!
  end

end
