class Collection < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user, :counter_cache => true
  has_many :collection_parts, :dependent => :destroy
  has_many :products, :through => :collection_parts

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :for_user, lambda {|user_id| {:conditions => {
                                              :user_id => user_id}}}
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :by_id, :order => 'id DESC'
  named_scope :with_products, :include => :products
  named_scope :with_user, :include => :user

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

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


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id,:user_id,:created_at]

    options[:include] = {}
    options[:include].store(:products,{:only => [:id],:methods => [:photo_url]})
    options[:include].store(:user,{:only => [:id,:handle]})

    super(options)
  end
end
