class Store < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user
  has_many    :products

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :name
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new store
  #
  def self.add(name,user_id)
    find_or_create_by_name(
      :name     => name.squeeze(' ').strip,
      :user_id  => user_id)
  end


  # Fetch a store from a name
  #
  def self.fetch(name)
    find_by_name(name.squeeze(' ').strip)
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Edit attributes of the model
  #
  def edit(attributes)
    self.name         = attributes[:name]
    self.is_approved  = true

    self.save!
  end

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    super(options.merge(:only => [:id,:name]))
  end



end
