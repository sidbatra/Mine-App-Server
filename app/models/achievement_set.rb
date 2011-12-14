class AchievementSet < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------
  STAR_USERS    = 'star_users'
  TOP_SHOPPERS  = 'top_shoppers'

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many :achievements, :dependent => :destroy

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :owner_id
  validates_presence_of   :for
  validates_inclusion_of  :for, :in => [STAR_USERS,TOP_SHOPPERS]

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new achievement set 
  #
  def self.add(owner_id,type,entities,user_ids)
    achievement_set = new(
                        :owner_id => owner_id,
                        :for      => type)

    raise IOError, "No achievements added to set" unless user_ids.present?

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
    add(0,STAR_USERS,users,users.map(&:id))
  end

  # Add an achievement set for top shoppers 
  # of a given store
  #
  def self.add_top_shoppers(store_id,users)
    add(store_id,TOP_SHOPPERS,users,users.map(&:id))
  end

  # Fetch the star users from the database. This set of users is the
  # one which will be displayed on the website at any given time
  #
  def self.star_users
    achievement_set = find_last_by_for(STAR_USERS)
    achievement_set ? Achievement.achievers(achievement_set.id) : []
  end

  # Fetch the top shoppers for a given store from the database. This set of
  # top shoppers will be displayed on the website at any given time
  #
  def self.top_shoppers(store_id)
    achievement_set = find_last_by_for_and_owner_id(TOP_SHOPPERS,store_id)
    achievement_set ? Achievement.achievers(achievement_set.id) : []
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Find the achivement set of the same kind created just before
  #
  def previous
    self.class.last(
      :conditions => {
        :for            => self.for,
        :owner_id       => self.owner_id,
        :created_at_lte => self.created_at,
        :id_ne          => self.id})
  end

  # Add an expiry date to the achivement set
  #
  def expire
    self.expired_at = Time.now
    self.save!
  end

  # Is set for star users
  #
  def for_star_users?
    self.for == STAR_USERS
  end

  # Is set for top shoppers
  #
  def for_top_shoppers?
    self.for == TOP_SHOPPERS
  end

end
