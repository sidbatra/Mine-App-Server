class Product < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  before_save :populate_handle

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :title
  validates_presence_of   :endorsement
  validates_presence_of   :image_url
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :eager, :include => :user

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new product
  #
  def self.add(attributes,user_id)
    create(
      :title        => attributes['title'],
      :endorsement  => attributes['endorsement'],
      :website_url  => attributes['website_url'],
      :image_url    => attributes['image_url'],
      :query        => attributes['query'],
      :user_id      => user_id)
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Populate handle from the product title
  #
  def populate_handle
    return unless self.title.present? 

    self.handle = self.title.gsub(/[^a-zA-Z0-9\.]/,'-').
                              squeeze('-').
                              chomp('-')
  end

end
