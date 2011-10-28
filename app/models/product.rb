class Product < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user, :counter_cache => true
  has_many    :comments

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  before_save :populate_handle

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :title
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

  # Share the product to fb via the user who created it
  #
  def share(product_url)
    return if self.is_shared

    fb_user = FbGraph::User.me(self.user.access_token)
    fb_user.feed!(
      :message      => self.endorsement,
      :picture      => self.thumbnail_url,
      :link         => product_url,
      :description  => "#{self.user.first_name} is using Felvy to share what "\
                        "#{self.user.gender == "male" ? "he" : "she"} buys "\
                        "and owns. It's fun, and free!",
      :name         => self.title)

      self.shared
  end

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
