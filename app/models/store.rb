class Store < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to  :user
  has_many    :products
  has_many    :shoppings,   :dependent => :destroy

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :name
  validates_presence_of   :user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_products, :include => :products
  named_scope :approved,    :conditions => {:is_approved => true}
  named_scope :unapproved,  :conditions => {:is_approved => false}
  named_scope :processed,   :conditions => {:is_processed => true}
  named_scope :sorted,      :order      => 'name ASC'
  named_scope :popular,     :order      => 'products_count DESC'
  named_scope :products_count_gt, lambda {|count| {
                                  :conditions => {
                                    :products_count_gt => count}}}
  named_scope :for_user,    lambda {|user_id| {
                                :joins      => :shoppings,
                                :conditions => {:shoppings => {
                                                  :user_id => user_id}},
                                :order      => 'shoppings.products_count DESC'}}

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :rehost, :reupdate_domain, :reupdate_metadata
  attr_accessible :name,:user_id,:image_path,:is_approved,
                    :domain,:byline,:description,:favicon_path

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new store
  #
  def self.add(name,user_id)
    find_or_create_by_name(
      :name     => name.squeeze(' ').strip,
      :user_id  => user_id)
  end

  # Fetch a store by name 
  #
  def self.fetch(name)
    find_by_name(name.squeeze(' ').strip) 
  end

  # Update top shoppers across popular stores
  #
  def self.update_top_shoppers
    Store.processed.popular.each do |store|
      begin
        top_shoppers = store.update_top_shoppers

        yield store,top_shoppers if block_given?

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)    
      end
    end 
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Flag if the store is a top store
  #
  def is_top
    is_processed
  end


  # Move all products to an existing store
  #
  def move_products_to(store)
    self.products.each do |product|
      product.store_id = store.id
      product.save!
    end
  end

  # Change the store to unknown for all products 
  #
  def change_products_store_to_unknown
    self.products.each do |product|
      product.make_store_unknown
    end
  end

  # Relative path on the filesystem for the processed image thumbnail
  #
  def thumbnail_path
    't_' + image_path
  end

  # Relative path on the filesystem for the processed medium image
  #
  def medium_path
    'm_' + image_path
  end

  # Relative path on the filesystem for the processed large image
  #
  def large_path
    'l_' + image_path
  end

  # Full url of the thumbnail of the image
  #
  def thumbnail_url
    is_processed ? FileSystem.url(thumbnail_path) : image_url
  end

  # Full url of the medium copy of the image
  #
  def medium_url
    is_processed ? FileSystem.url(medium_path) : image_url
  end

  # Full url of the large copy of the image
  #
  def large_url
    is_processed ? FileSystem.url(large_path) : image_url
  end

  # Full url of the store favicon
  #
  def favicon_url
    favicon_path ? 
      FileSystem.url(favicon_path) : 
      (image_path ? thumbnail_url : "")
  end

  # Full url of the original image
  #
  def image_url
    FileSystem.url(image_path ? image_path : "")
  end

  # Update the domain for the store. 
  #
  def update_domain
    web_search  = WebSearch.on_pages(name,1)
    self.domain = URI.parse(web_search.Web["Results"][0]["Url"]).host

    save! 
  end

  # Use store domain to update metadata
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

  # Fetch favicon from the given url and host it
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

  # Save store image to filesystem and create smaller copies
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

  # Update the top shoppers at the store. Returns
  # shoppers who have recently become top shoppers
  #
  def update_top_shoppers
    old_shoppers = AchievementSet.current_top_shoppers(self.id).
                    map(&:achievable).
                    map(&:id)
    old_shoppers = Hash[*old_shoppers.zip([true] * old_shoppers.length).flatten]

    new_shoppers = User.top_shoppers(self.id).limit(20)

    AchievementSet.add(
      self.id,
      AchievementSetFor::TopShoppers,
      new_shoppers,
      new_shoppers.map(&:id))

    new_shoppers.reject{|u| old_shoppers.key?(u.id)}
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
