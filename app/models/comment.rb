class Comment < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :product, :counter_cache => true

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :data
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

  # Add a new comment
  #
  def self.add(attributes,user_id)
    create!(
      :data         => attributes['data'],
      :product_id   => attributes['product_id'],
      :user_id      => user_id)
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id,:data,:created_at]

    options[:include] = {}
    options[:include].store(*(User.json_options))

    super(options)
  end

end
