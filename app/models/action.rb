class Action < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :product, :counter_cache => true

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :name
  validates_inclusion_of  :name, :in => ['like','own','want']
  validates_presence_of   :user_id
  validates_presence_of   :product_id

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :with_user, :include => :user
  named_scope :on_product, lambda {|product_id| 
                            {:conditions => {:product_id => product_id}}}
  named_scope :by_id, :order => 'id DESC'

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new action
  #
  def self.add(attributes,user_id)
    find_or_create_by_product_id_and_name_and_user_id(
      :product_id   => attributes['product_id'],
      :name         => attributes['name'],
      :user_id      => user_id)
  end

  # Fetch an ownership entry for a product by a user
  # return nil if not found
  def self.fetch_own_for_product_and_user(product_id,user_id)
    find_by_product_id_and_name_and_user_id(product_id,'own',user_id)
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id,:name,:user_id]

    options[:include] = {}
    options[:include].store(*(User.json_options))

    super(options)
  end

end
