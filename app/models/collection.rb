class Collection < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  has_many :collection_parts, :dependent => :destroy
  has_many :products, :through => :collection_parts

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new collection
  #
  def self.add
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id]

    options[:include] = {}
    #options[:include].store(*(User.json_options))

    super(options)
  end
end
