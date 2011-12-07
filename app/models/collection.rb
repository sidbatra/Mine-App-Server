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
  def self.add(product_ids,user_id)
    collection = Collection.new(:user_id => user_id)

    raise IOError, "No products added to collection" unless product_ids.present?

    product_ids.uniq.each do |product_id|
      collection.collection_parts.build(:product_id => product_id)
    end

    collection.save!
    collection
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
