class Store < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user
  has_many    :products

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :generate_handle

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  before_save :populate_handle

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :name
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :approved,    :conditions => {:is_approved => true}
  named_scope :unapproved,  :conditions => {:is_approved => false}
  named_scope :processed,   :conditions => {:is_processed => true}
  named_scope :sorted,      :order      => 'name ASC'
  named_scope :popular,     :order      => 'products_count DESC'

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

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

  # Fetch sorted list of top stores
  #
  def self.top
    Cache.fetch('top_stores') {Store.processed.popular.all(:limit => 25)}
  end

  # Return json options specifiying which attributes and methods
  # to pass in the json when the model is used within an include
  # of another model's json
  #
  def self.json_options
    options             = {}
    options[:only]      = [:id,:name]
    options[:methods]   = []

    [self.name.downcase.to_sym,options]
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Edit attributes of the model
  #
  def edit(attributes)

    if attributes[:name].present?
      self.name = attributes[:name]
    end

    if attributes[:is_approved].present?
      self.is_approved  = attributes[:is_approved] 
    end

    self.save!
  end

  # Return product count for the given category
  #
  def products_category_count(category_id)
    Cache.fetch(KEYS[:store_category_count] % [self.id,category_id]) do
      Product.for_store(self.id).in_category(category_id).count 
    end
  end

  # Total price of all the products
  #
  def products_price
    Cache.fetch(KEYS[:store_price] % self.id) do
      Product.for_store(self.id).sum(:price) 
    end
  end


  # Move all products to an existing store
  #
  def move_products_to(store)
      products_updated  = Product.update_all(
                            {:store_id => store.id},
                            {:store_id => self.id})

      Store.update_counters(
              store.id,
              :products_count => products_updated)
  end

  # Relative path on the filesystem for the processed image thumbnail
  #
  def thumbnail_path
    't_' + image_path
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

  # Full url of the large copy of the image
  #
  def large_url
    is_processed ? FileSystem.url(large_path) : image_url
  end

  # Full url of the original image
  #
  def image_url
    FileSystem.url(image_path)
  end

  # Save store image to filesystem and create smaller copies
  #
  def host(file_path)
    self.image_path  = Base64.encode64(
                         SecureRandom.hex(10) + 
                         Time.now.to_i.to_s).chomp + ".gif"

    if File.exists? file_path

      # Store original image
      #
      FileSystem.store(
        image_path,
        open(file_path),
        "Content-Type"  => "image/gif",
        "Expires"       => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create tiny thumbnail
      #
      image = MiniMagick::Image.from_file(file_path)

      ImageUtilities.reduce_to_with_image(
                        image,
                        {:width => 40,:height => 40})

      FileSystem.store(
        thumbnail_path,
        open(image.path),
        "Content-Type"  => "image/gif",
        "Expires"       => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create large thumbnail
      #
      image = MiniMagick::Image.from_file(file_path)

      ImageUtilities.reduce_to_with_image(
                        image,
                        {:width => 50,:height => 50})

      FileSystem.store(
        large_path,
        open(image.path),
        "Content-Type" => "image/gif",
        "Expires"       => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))


      self.is_processed  = true
      self.save(false)
    end
  end

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]      = [] if options[:only].nil?
    options[:only]     += [:id,:name,:handle]

    options[:methods]   = [] if options[:methods].nil?
    options[:methods]  += [:thumbnail_url]

    super(options)
  end


  protected

  # Populate handle for the store
  #
  def populate_handle
    return unless !self.handle.present? || self.generate_handle

    self.handle = (self.name).
                      gsub(/[^a-zA-Z0-9]/,'-').
                      squeeze('-').
                      chomp('-')
    
    self.handle = rand(1000000) if self.handle.empty?


    base  = self.handle
    tries = 1

    # Create uniqueness
    while(true)
      match = self.class.find_by_handle(base)
      break unless match.present? && match.id != self.id

      base = self.handle + '-' + tries.to_s
      tries += 1
    end

    self.handle = base
  end

end
