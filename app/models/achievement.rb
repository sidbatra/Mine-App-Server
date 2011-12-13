class Achievement < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :achievement_set
  belongs_to  :achievable, :polymorphic => true

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :achievable_id
  validates_presence_of   :achievable_type
  validates_inclusion_of  :achievable_type, :in => %w(User Product)
  validates_presence_of   :user_id
  validates_presence_of   :achievement_set_id

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :achievers, lambda {|achievement_set_id| {
                    :conditions => {:achievement_set_id => achievement_set_id},
                    :include    => :achievables}}

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new achievement 
  #
  def self.add(entity,achievement_set_id,user_id)
    create!(
      :achievable_id        => entity.id,
      :achievable_type      => entity.class.name,
      :achievement_set_id   => achievement_set_id,
      :user_id              => user_id)
  end

  # Fetch the star users from the database. This set of users is the
  # one which will be displayed on the website at any given time
  #
  def self.star_users
    achievement_set = AchievementSet.find_last_by_type('star_users')
    achievers(achievement_set.id)
  end

end
