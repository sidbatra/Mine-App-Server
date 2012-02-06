class AchievementSet < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_many :achievements, :dependent => :destroy

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :owner_id
  validates_inclusion_of  :for, :in => AchievementSetFor.values

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new achievement set 
  #
  def self.add(owner_id,type,entities,user_ids)
    achievement_set = new(
                        :owner_id => owner_id,
                        :for      => type)

    raise IOError, "Malformed arguments" unless user_ids.present? && 
                                                entities.present? && 
                                                entities.length == user_ids.length

    entities.zip(user_ids).each do |entity,user_id|
      achievement_set.achievements.build(
                                    :achievable_id        => entity.id,
                                    :achievable_type      => entity.class.name,
                                    :user_id              => user_id)
    end

    achievement_set.save!
    achievement_set
  end

  # Fetch achievers for last set owned by the given id and for the given
  # purpose
  #
  def self.achievers_for_set_owned_by(achievement_set_for,owner_id)
    set = find_last_by_for_and_owner_id(achievement_set_for,owner_id)
    set ? Achievement.achievers(set.id) : []
  end

  # Extend the method_missing method for a uniform interface
  # to fetch achievers of current achievement sets
  #
  def self.method_missing(method,*args)

    if method.to_s.match(/^current_(.*)/)
      type = AchievementSetFor.class_eval($1.titleize.gsub(' ',''))

      achievers_for_set_owned_by(
        type,
        type == AchievementSetFor::StarUsers ? 
                  AchievementSetOwner::Automated : 
                  args.first)
    else
      super
    end
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

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

  # Check if the achievement set has expired
  #
  def expired?
    self.expired_at.present?
  end

end
