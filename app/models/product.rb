class Product < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user
  has_many    :comments

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
  named_scope :eager, :include => [:user,:comments]

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new product
  #
  def self.add(attributes,user_id)
    create(
      :title        => attributes['title'],
      :endorsement  => attributes['endorsement'],
      :category     => attributes['category'],
      :website_url  => attributes['website_url'],
      :image_url    => attributes['image_url'],
      :thumb_url    => attributes['thumb_url'],
      :is_hosted    => attributes['is_hosted'],
      :query        => attributes['query'],
      :user_id      => user_id)
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Fetch the next product uploaded by the user
  # who owns the product
  #
  def next
    self.class.first(
                :conditions => {
                    :user_id  => self.user_id,
                    :id_gt    => self.id})
  end

  # Fetch the previous product uploaded by the user
  # who owns the product
  #
  def previous
    self.class.last(
                :conditions => {
                    :user_id  => self.user_id,
                    :id_lt    => self.id})
  end

  # Mark the product as shared
  #
  def shared
    self.is_shared = true
    save!
  end

  # Generate url for the photo
  #
  def photo_url
    is_hosted ? FileSystem.url(image_url) : image_url
  end

  # Conditional upon hosting and thumb_url status
  #
  def thumbnail_url
    !is_hosted && thumb_url.present? ? thumb_url : photo_url
  end


  protected

  # Populate handle from the product title
  #
  def populate_handle
    return unless self.title.present? 

    self.handle = self.title.gsub(/[^a-zA-Z0-9]/,'-').
                              squeeze('-').
                              chomp('-')
  end

end
