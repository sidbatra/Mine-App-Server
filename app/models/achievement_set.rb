class AchievementSet < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :achievements, :dependent => :destroy

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :owner_id
  validates_presence_of   :type
  validates_inclusion_of  :type, :in => %w(star_users top_shoppers)

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new achievement set 
  #
  def self.add(owner_id,type)
    create!(
      :owner_id   => owner_id,
      :type       => type)
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Add an expiry date to the achivement set
  #
  def expire
    self.expired_at = Time.now
    self.save!
  end

end
