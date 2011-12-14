class AchievementSet < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :achievements, :dependent => :destroy

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :owner_id
  validates_presence_of   :for
  validates_inclusion_of  :for, :in => %w(star_users top_shoppers)

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new achievement set 
  #
  def self.add(owner_id,type,entities,user_ids)
    achievement_set = AchievementSet.new(
                                      :owner_id => owner_id,
                                      :for      => type)

    entities.zip(user_ids).each do |entity,user_id|
      achievement_set.achievements.build(
                                    :achievable_id        => entity.id,
                                    :achievable_type      => entity.class.name,
                                    :user_id              => user_id)
    end

    achievement_set.save!
    achievement_set
  end

  # Add an achievement set for star users
  #
  def self.add_star_users(users)
    add(0,'star_users',users,users.map(&:id))
  end

  # Fetch the star users from the database. This set of users is the
  # one which will be displayed on the website at any given time
  #
  def self.star_users
    achievement_set = find_last_by_for('star_users')
    Achievement.achievers(achievement_set.id)
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
