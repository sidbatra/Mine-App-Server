class Product < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :store
  has_many :purchases

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :title,:source_url,:orig_image_url,:external_id

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :title
  validates_presence_of :orig_image_url
  validates_presence_of :source_url

  #----------------------------------------------------------------------
  # Callbacks
  #----------------------------------------------------------------------
  before_save :populate_hash

  #----------------------------------------------------------------------
  # Indexing
  #----------------------------------------------------------------------
  searchable do
    integer :store_id
    text :title, :boost => 5
    text :description
    text :store, :boost => 2 do
      store ? store.name : ""
    end
    text :tags, :boost => 3 do
      tags 
    end
  end

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :for_store, lambda {|store_id| {:conditions => {
                                      :store_id => store_id}}}
  named_scope :with_store, :include => :store
  named_scope :with_purchases, :include => :purchases

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Public. Override base method functionality. Fetch a product using
  # a link to it's orig_image_url. The orig_image_url is hashed and
  # compared against the orig_image_url_hash column.
  #
  # orig_image_url - The String representing the original image url.
  #
  # Returns the Product object is found, nil otherwise.
  #
  def self.find_by_orig_image_url(orig_image_url)
    find_by_orig_image_url_hash(Digest::SHA1.hexdigest(orig_image_url))
  end

  # Public. Perform full text search on all the indexed products using 
  # solr + sunpot.
  #
  # query - The String query.
  # store_id - The Integer store_id to search. (default: nil).
  # page - The Integer page number of results (default: 1).
  # per_page - The Integer number of results per page (default: 10).
  # 
  # returns - An Array of product models matching the given query.
  #
  def self.fulltext_search(query,store_id=nil,page=1,per_page=10)
    search = search do 
                fulltext query
                with(:store_id, store_id) if store_id.present?
                paginate :per_page => per_page, :page => page
             end

    [search.results,search.total]
  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
    [[],0]
  end

  # Public. Load crawled products from an S3 bucket and import tme
  # into the database.
  #
  # bucket - The String name of the S3 bucket.
  # prefix - The String prefix marking where the products are in the bucket.
  #
  # Returns nothing
  #
  def self.import_crawled(bucket,prefix)
    columns = [:title,:description,:source_url,:orig_image_url,
                :orig_image_url_hash,:store_id]
                
    AWS::S3::Bucket.objects(bucket,:prefix => prefix).each do |object|
      next if object.key.match("\\$folder\\$")

      values = []

      object.value.split("\n").each do |line|
        product = line.split("\t")

        source_url          = product[0]
        title               = product[1]
        orig_image_url      = product[2]
        orig_image_url_hash = Digest::SHA1.hexdigest(orig_image_url)
        store_id            = product[3]
        description         = product[4]

        values << [title,description,source_url,orig_image_url,
                    orig_image_url_hash,store_id]
      end #lines

      Product.import columns,values,{:validate => false}
    end #files


    products = Product.find_all_by_is_processed(false)

    products.each do |product|
      SecondaryProcessingQueue.push(
        ProductDelayedObserver,
        :after_create,
        product.id)
    end

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  def tags
    self[:tags].present? ? self[:tags].split(CONFIG[:tag_boundary]) : ""
  end

  def tags=(new_tags)
    self[:tags] = new_tags.join(CONFIG[:tag_boundary]) if new_tags
  end


  # Public. Relative path of the thumbnail image on the filesystem.
  #
  # Returns the String thumbnail image path.
  #
  def thumbnail_path
    "t_" + image_path
  end

  # Public. Thumbnail url conditioned on processing state. Filesystem
  # url if processed original sized image url if not.
  #
  # Returns the String thumbnail url.
  #
  def thumbnail_url
    is_processed ? 
      FileSystem.url(thumbnail_path) :
      orig_image_url
  end

  # Public. Image url conditioned on processing state. Filesystem
  # url if processed original image url if not.
  #
  # Returns the String image url.
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

    system("wget --no-check-certificate "\
            "-U '#{CONFIG[:user_agent]}' '#{orig_image_url}' "\
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

      # Create thumbnail
      #
      image = MiniMagick::Image.open(file_path)

      ImageUtilities.reduce_to_with_image(
                        image,
                        {:width => 180,:height => 180})

      FileSystem.store(
        thumbnail_path,
        open(image.path),
        "Content-Type" => "image/jpeg",
        "Expires"      => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      self.is_processed = true
      self.save!
    end

  rescue MiniMagick::Invalid => ex
    LoggedException.add(__FILE__,__method__,ex)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  protected

  # Protected. Populate the orig_image_url_hash field uses a 
  # SHA1 hexdigest of the orig_image_url.
  #
  def populate_hash
    self.orig_image_url_hash = Digest::SHA1.hexdigest orig_image_url
  end

end
