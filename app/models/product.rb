class Product < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to  :user,  :counter_cache => true
  belongs_to  :store, :counter_cache => true
  belongs_to  :suggestion
  has_many    :achievements,    :as => :achievable,   :dependent => :destroy
  has_many    :ticker_actions,  :as => :ticker_actionable, 
                                :dependent => :destroy

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of     :title
  validates_presence_of     :price
  validates_presence_of     :orig_image_url
  validates_inclusion_of    :is_gift, :in => [true,false]
  validates_presence_of     :user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user,   :include => :user
  named_scope :with_store,  :include => :store
  named_scope :by_id,       :order => 'id DESC'
  named_scope :for_ids,     lambda {|ids| {:conditions => {:id => ids}}}
  named_scope :for_user,    lambda {|user_id| 
                              {:conditions => {:user_id => user_id}}}
  named_scope :for_store,   lambda {|store_id| 
                              {:conditions => {:store_id => store_id}}}
  named_scope :not_for_user, lambda {|user_id| 
                              {:conditions => {:user_id_ne => user_id}}}
  named_scope :created,     lambda {|range| 
                              {:conditions => {:created_at => range}}}


  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :is_store_unknown, :store_name, :rehost
  attr_accessible :title,:source_url,:orig_image_url,:orig_thumb_url,:is_hosted,
                  :query,:price,:endorsement,:is_gift,:store_id,:user_id,
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

  # Add a new product
  #
  def self.add(attributes,user_id)
    create!(
      :title              => attributes['title'].strip,
      :source_url         => attributes['source_url'],
      :orig_image_url     => attributes['orig_image_url'],
      :orig_thumb_url     => attributes['orig_thumb_url'],
      :is_hosted          => attributes['is_hosted'],
      :query              => attributes['query'],
      :price              => attributes['price'],
      :endorsement        => attributes['endorsement'].strip,
      :is_gift            => attributes['is_gift'],
      :suggestion_id      => attributes['suggestion_id'],
      :store_id           => attributes['store_id'],
      :source_product_id  => attributes['source_product_id'],
      :user_id            => user_id)
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

  # Mark the store as unknown
  #
  def make_store_unknown
    self.store_id = nil
    save!
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

  # Path on filesystem for the processed hosted image thumbnail
  #
  def thumbnail_path
    "t_" + image_path
  end

  # Path on filesystem for the processed hosted giant image
  #
  def giant_path
    "g_" + image_path
  end

  # Url of the largest copy of the image
  #
  def image_url
    is_hosted ?
      FileSystem.url(image_path) : 
      orig_image_url
  end
  
  # Url of the giant copy of the image
  #
  def giant_url
    is_hosted ?
      FileSystem.url(giant_path) : 
      orig_image_url
  end

  # Generate url for the photo
  #
  def photo_url
    is_hosted ? 
      FileSystem.url(is_processed ? giant_path : image_path) : 
      orig_image_url
  end

  # Conditional upon hosting and orig_thumb_url status
  #
  def thumbnail_url
    is_hosted ? 
      FileSystem.url(is_processed ? thumbnail_path : image_path) :
      (orig_thumb_url.present? ? orig_thumb_url : orig_image_url)
  end

  # Pull image from source and host on S3
  #
  def host
    self.image_path  = Base64.encode64(
                         SecureRandom.hex(10) + 
                         Time.now.to_i.to_s).chomp + ".jpg"

    tempfile         = Tempfile.new(image_path)
    file_path        = tempfile.path

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
        "Expires"       => 1.year.from_now.
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
        "Expires"       => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))


      self.is_hosted     = true
      self.is_processed  = true
      self.save(false)
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
