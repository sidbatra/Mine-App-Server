class Search < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :query
  validates_presence_of   :user_id
  validates_presence_of   :source
  validates_inclusion_of  :source, :in => SearchSource.values

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method for creating a new search.
  #
  def self.add(attributes,user_id)
    attributes[:user_id] = user_id
    create!(attributes)
  end

end
