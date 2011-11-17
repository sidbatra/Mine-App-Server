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


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id,:name]

    options[:include] = {}
    options[:include].store(*(User.json_options))

    super(options)
  end

end
