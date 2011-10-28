class Search < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :query
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new search
  #
  def self.add(attributes,user_id)
    create!(
      :query        => attributes['query'],
      :user_id      => user_id)
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    super(options.merge(:only => [:id,:query]))
  end

end
