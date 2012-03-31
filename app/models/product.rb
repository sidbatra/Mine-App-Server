class Product < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user,  :counter_cache => true
  belongs_to :store, :counter_cache => true
  belongs_to :suggestion

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :title
  validates_presence_of :orig_image_url
  validates_presence_of :user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user,  :include => :user
  named_scope :with_store, :include => :store
  named_scope :by_id,      :order => 'id DESC'

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :is_store_unknown, :store_name, :rehost
  attr_accessible :title,:source_url,:orig_image_url,:orig_thumb_url,
                  :query,:endorsement,:store_id,:user_id,
                  :source_product_id,:suggestion_id

  #----------------------------------------------------------------------
  # Indexing
  #----------------------------------------------------------------------
  searchable do
    text :title, :boost => 2
    text :query
    text :store do
      store ? store.name : ""
    end
  end

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method to create a new product.
  #
  # returns - Product. Newly created product object.
  #
  def self.add(attributes,user_id)
    attributes[:title]        = attributes[:title].strip
    attributes[:endorsement]  = attributes[:endorsement].strip
    attributes[:user_id]      = user_id

    create!(attributes)
  end

  # Perform full text search on all the indexed products using 
  # solr + sunpot.
  #
  # query - String. Full text search query.
  # page - Integer:1. Pagination - the page of results to fetch
  # per_page - Integer:10. Pagination - number of results per page
  # 
  # returns - Array. Array of product models matching the given query.
  #
  def self.fulltext_search(query,page=1,per_page=10)
    Product.search do 
              fulltext query
              paginate :per_page => per_page, :page => page
            end.results
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Mark the product's store as unknown by setting store_id
  # to nil.
  #
  def make_store_unknown
    self.store_id = nil
    save!
  end

  # Fetch the next product created by the user who created
  # this product.
  #
  def next
    self.class.first(
      :conditions => {
        :user_id  => self.user_id,
        :id_gt    => self.id})
  end

  # Fetch the previous product created by the user who created
  # this product.
  #
  def previous
    self.class.last(
      :conditions => {
        :user_id  => self.user_id,
        :id_lt    => self.id})
  end

  # Path on filesystem for the processed hosted image thumbnail.
  #
  def thumbnail_path
    "t_" + image_path
  end

  # Path on filesystem for the processed hosted giant image.
  #
  def giant_path
    "g_" + image_path
  end

  # Conditional upon hosting and orig_thumb_url status.
  #
  def thumbnail_url
    is_processed ? 
      FileSystem.url(thumbnail_path) :
      (orig_thumb_url.present? ? orig_thumb_url : orig_image_url)
  end
  
  # Url of the giant copy of the image.
  #
  def giant_url
    is_processed ?
      FileSystem.url(giant_path) : 
      orig_image_url
  end

  # Url of the largest copy of the image.
  #
  def image_url
    is_processed ?
      FileSystem.url(image_path) : 
      orig_image_url
  end

  # Fetch image from the original source and host it on the Filesystem
  # along with copies at various sizes.
  #
  def host
    self.image_path = Base64.encode64(
                       SecureRandom.hex(10) + 
                       Time.now.to_i.to_s).chomp + ".jpg"

    tempfile  = Tempfile.new(image_path)
    file_path = tempfile.path

    system("wget -U '#{CONFIG[:user_agent]}' '#{orig_image_url}' "\
            "-T 30 -t 3 "\
            "--output-document '#{file_path}'")


    if File.exists? file_path

      # Store original image
      #
      FileSystem.store(
        image_path,
        open(file_path),
        "Content-Type"  => "image/jpeg",
        "Expires"       => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create tiny thumbnail
      #
      image = MiniMagick::Image.open(file_path)

      ImageUtilities.reduce_to_with_image(
                        image,
                        {:width => 130,:height => 130})

      FileSystem.store(
        thumbnail_path,
        open(image.path),
        "Content-Type" => "image/jpeg",
        "Expires"      => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create giant thumbnail
      #
      image = MiniMagick::Image.open(file_path)

      ImageUtilities.reduce_to_with_image(
                        image,
                        {:width => 370,:height => 350})

      FileSystem.store(
        giant_path,
        open(image.path),
        "Content-Type" => "image/jpeg",
        "Expires"      => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      self.is_processed = true
      self.save!
    end

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end


  protected

  # Required by Handler mixin to create base handle
  #
  def handle_base
    title
  end

  # Required by Handler mixin to test uniqueness of handle
  #
  def handle_uniqueness_query(handle)
    self.class.find_by_handle_and_user_id(handle,user_id)
  end

end
