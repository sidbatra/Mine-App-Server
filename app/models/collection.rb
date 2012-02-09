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
  named_scope :with_products_and_associations,
              :include => {:products => [:store,:user]}
  named_scope :with_user, :include => :user

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :name,:user_id

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new collection
  #
  def self.add(product_ids,name,user_id)
    collection = new(
                  :user_id  => user_id,
                  :name     => name)

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

  # Destroy the old collection parts and make new ones
  #
  def update_parts(new_product_ids)
    collection_parts.destroy_all

    new_product_ids.uniq.each do |product_id|
      collection_parts.build(:product_id => product_id)
    end

    save!
  end

  # Fetch the next collection made by the owner 
  #
  def next
    self.class.first(
                :conditions => {
                    :user_id  => self.user_id,
                    :id_gt    => self.id})
  end

  # Fetch the previous collection made by the owner 
  #
  def previous
    self.class.last(
                :conditions => {
                    :user_id  => self.user_id,
                    :id_lt    => self.id})
  end

  # Full url of the original image
  #
  def image_url
    FileSystem.url(image_path ? image_path : "")
  end

  # Generate an canonical image using products
  # of the collection
  #
  def process
    return if products.length < 4

    self.image_path  = Base64.encode64(
                         SecureRandom.hex(10) + 
                         Time.now.to_i.to_s).chomp + ".jpg"

    base = MiniMagick::Image.open(
            File.join(RAILS_ROOT,CONFIG[:collection_base_image]))
    coordinates = [[8,8],[90,8],[8,90],[90,90]]
    thumbnail_size = 82

    products.shuffle[0..3].each_with_index do |product,i|
      image = MiniMagick::Image.open(product.thumbnail_url)
      image = ImageUtilities.square_thumbnail_with_image(image,thumbnail_size)

      size = image[:width] > image[:height] ?
              "#{thumbnail_size}x#{(image[:height]*thumbnail_size)/image[:width]}" :
              "#{thumbnail_size}x#{(image[:width]*thumbnail_size)/image[:height]}"

      base = base.composite(image) do |canvas|
        canvas.gravity  "NorthWest"
        canvas.geometry "#{size}+#{coordinates[i].join('+')}"
      end
    end

    FileSystem.store(
      image_path,
      open(base.path),
      "Content-Type"  => "image/jpg",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))

    self.is_processed = true
    save!
  end

end
