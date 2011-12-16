class Category < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  has_many    :products

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of     :name
  validates_presence_of     :handle
  validates_presence_of     :weight
  validates_numericality_of :weight

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :weighted, :order => 'weight DESC'

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new category
  #
  def self.add(name,handle,weight=0)
    find_or_create_by_handle(
      :name     => name,
      :handle   => handle,
      :weight   => weight)
  end

  # Find category by handle
  #
  def self.fetch(handle)
    find_by_handle(handle)
  end

  ##
  # Fetch all categories sorted by weight
  def self.fetch_all
    Cache.fetch('category_all'){weighted}
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    super(options.merge(:only => [:id,:name,:handle]))
  end

end
