class TickerAction < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :ticker_actionable, :polymorphic => true
  belongs_to :user

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :og_action_id
  validates_inclusion_of  :og_action_type, :in => OGAction.values
  validates_presence_of   :ticker_actionable_id
  validates_inclusion_of  :ticker_actionable_type, :in => %w(Product Collection)

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new ticker action 
  #
  def self.add(og_action_id,og_action_type,ticker_actionable)
    create!(
      :og_action_id             => og_action_id,
      :og_action_type           => og_action_type,
      :ticker_actionable_id     => ticker_actionable.id,
      :ticker_actionable_type   => ticker_actionable.class.name) 
  end

end
