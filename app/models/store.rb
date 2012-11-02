class Store < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to  :user
  has_one     :crawl_datum, :dependent => :destroy
  has_one     :email_parse_datum, :dependent => :destroy
  has_many    :purchases
  has_many    :products
  has_many    :shoppings, :dependent => :destroy

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :name
  validates_presence_of   :user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_purchases, :include => :purchases
  named_scope :with_crawl_datum, :include => :crawl_datum
  named_scope :with_email_parse_datum, :include => :email_parse_datum
  named_scope :approved,    :conditions => {:is_approved => true}
  named_scope :unapproved,  :conditions => {:is_approved => false}
  named_scope :processed,   :conditions => {:is_processed => true}
  named_scope :crawlable,   :joins => :crawl_datum, 
                            :conditions => {:crawl_data => {:active => true}}
  named_scope :parseable,   :joins => :email_parse_datum, 
                            :conditions => {:email_parse_data => 
                                              {:is_active => true}},
                            :order => 'email_parse_data.weight DESC'
  named_scope :sorted,      :order      => 'name ASC'
  named_scope :popular,     :order      => 'purchases_count DESC'
  named_scope :purchases_count_gt, lambda {|count| {
                  :conditions => {:purchases_count_gt => count}}}

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :rehost, :reupdate_domain, :reupdate_metadata
  attr_accessible :name,:user_id,:image_path,:is_approved,
                    :domain,:byline,:description,:favicon_path

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method for creating a new store.
  #
  def self.add(name,user_id)
    find_or_create_by_name(
      :name     => name.squeeze(' ').strip,
      :user_id  => user_id)
  end

  # Fetch a store by name.
  #
  def self.fetch(name)
    find_by_name(name.squeeze(' ').strip) 
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Flag if the store is a top store
  #
  def is_top
    is_processed
  end

  # Move all purchases to an existing store.
  #
  # store - Store. Move all purchases to this store.
  #
  def move_purchases_to(store)
    self.purchases.each do |purchase|
      purchase.store_id = store.id
      purchase.save!
    end
  end

  # Change the store to unknown for all purchases.
  #
  def change_purchases_store_to_unknown
    self.purchases.each do |purchase|
      purchase.make_store_unknown
    end
  end

  # Relative path on the filesystem for the processed image thumbnail.
  #
  def thumbnail_path
    't_' + image_path
  end

  # Relative path on the filesystem for the processed medium image.
  #
  def medium_path
    'm_' + image_path
  end

  # Relative path on the filesystem for the processed large image.
  #
  def large_path
    'l_' + image_path
  end

  # Full url of the thumbnail of the image.
  #
  def thumbnail_url
    is_processed ? FileSystem.url(thumbnail_path) : image_url
  end

  # Full url of the medium copy of the image.
  #
  def medium_url
    is_processed ? FileSystem.url(medium_path) : image_url
  end

  # Full url of the large copy of the image.
  #
  def large_url
    is_processed ? FileSystem.url(large_path) : image_url
  end

  # Full url of the store favicon.
  #
  def favicon_url
    favicon_path ? 
      FileSystem.url(favicon_path) : 
      (image_path ? thumbnail_url : "")
  end

  # Full url of the original image.
  #
  def image_url
    FileSystem.url(image_path ? image_path : "")
  end

  # Update the domain for the store. 
  #
  def update_domain
    web_search  = WebSearch.on_pages(name,1)
    self.domain = URI.parse(web_search.results[0]["Url"]).host

    save! 
  end

  # Use store domain to update metadata.
  #
  def update_metadata
    return unless self.domain.present?

    url = 'http://' + domain
    webpage = Pismo::Document.new(url)

    self.byline       = webpage.title
    self.description  = webpage.description
    new_favicon_url   = webpage.favicon
    new_favicon_url ||= File.join url,'favicon.ico'

    host_favicon(new_favicon_url)

    save! 
  end

  # Fetch favicon from the given url and host it.
  #
  def host_favicon(new_favicon_url)
    old_favicon_path = favicon_path
    self.favicon_path  = Base64.encode64(
                           SecureRandom.hex(10) + 
                           Time.now.to_i.to_s).chomp + ".jpg"

    image = MiniMagick::Image.open(new_favicon_url)

    ImageUtilities.reduce_to_with_image(
                      image,
                      {:width => 64,:height => 64})

    FileSystem.store(
      favicon_path,
      open(image.path),
      "Content-Type"  => "image/jpeg",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))

  rescue => ex
    self.favicon_path = old_favicon_path
    LoggedException.add(__FILE__,__method__,ex)
  end

  # Create thumbnails for the store image and store them on the filesystem.
  #
  def host
    return unless self.image_path.present?

    # Create tiny thumbnail
    #
    image = MiniMagick::Image.open(self.image_url)

    ImageUtilities.reduce_to_with_image(
                      image,
                      {:width => 36,:height => 36})

    FileSystem.store(
      thumbnail_path,
      open(image.path),
      "Content-Type"  => "image/png",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))

    # Create medium thumbnail
    #
    image = MiniMagick::Image.open(self.image_url)

    ImageUtilities.reduce_to_with_image(
                      image,
                      {:width => 100,:height => 100})

    FileSystem.store(
      medium_path,
      open(image.path),
      "Content-Type"  => "image/png",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))

    # Create large thumbnail
    #
    image = MiniMagick::Image.open(self.image_url)

    ImageUtilities.reduce_to_with_image(
                      image,
                      {:width => 180,:height => 180})

    FileSystem.store(
      large_path,
      open(image.path),
      "Content-Type" => "image/png",
      "Expires"       => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))


    self.is_processed  = true
    self.save(false)

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end


  protected

  # Required by Handler mixin to create base handle
  #
  def handle_base
    name
  end

  # Required by Handler mixin to test uniqueness of handle
  #
  def handle_uniqueness_query(handle)
    self.class.find_by_handle(handle)
  end

end
