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
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :for_user, lambda {|user_id| {:conditions => {
                                              :user_id => user_id},
                                            :limit => 1}}

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new collection
  #
  def self.add(product_ids,user_id)
    collection = new(:user_id => user_id)

    raise IOError, "No products added to collection" unless product_ids.present?

    product_ids.uniq.each do |product_id|
      collection.collection_parts.build(:product_id => product_id)
    end

    collection.save!
    collection
  end

  # Fetch the last fresh collection for the given user_id
  #
  def self.fresh_for_user(user_id)
    for_user(user_id).last
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Test is the collection is less than a day old
  #
  def is_fresh
    (Time.now - self.created_at) < 86400
  end

  # Fetch product ids for the products in the collection
  #
  def product_ids
    collection_parts.map(&:product_id)
  end

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
