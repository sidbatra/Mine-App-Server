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

end
