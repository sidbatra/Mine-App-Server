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
  validates_inclusion_of  :source, :in => SearchSource.values

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :query,:user_id,:source

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user,  :include => :user
  named_scope :by_id,      :order => 'id DESC'
  named_scope :for, lambda{|source| {:conditions => {
                                      :source => source}}}

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
