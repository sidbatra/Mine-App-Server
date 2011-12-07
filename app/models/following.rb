class Following < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :follower, :class_name => "User"

  #-----------------------------------------------------------------------------
  # Validations 
  #-----------------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :follower_id
  validates_inclusion_of  :source, :in => %w(manual auto)

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :send_email

  #-----------------------------------------------------------------------------
  # Class Methods 
  #-----------------------------------------------------------------------------

  # Add a new following
  #
  def self.add(user_id,follower_id,source = 'manual',send_email = true)
    following = find_or_create_by_user_id_and_follower_id(
                  :user_id      => user_id,
                  :follower_id  => follower_id,
                  :source       => source,
                  :send_email   => send_email)

    unless following.is_active
      following.is_active = true
      following.save!
    end

    following
  end

  # Find a following
  #
  def self.fetch(user_id,follower_id)
    find_by_user_id_and_follower_id(user_id,follower_id)
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

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]      = [] if options[:only].nil?
    options[:only]     += [:id,:is_active]

    super(options)
  end


end
