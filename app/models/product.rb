class Product < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user  
  belongs_to  :store, :counter_cache => true
  has_many    :comments

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  before_save :populate_handle

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of     :title
  validates_presence_of     :price
  validates_numericality_of :price
  validates_presence_of     :orig_image_url
  validates_inclusion_of    :is_gift, :in => [true,false]
  validates_presence_of     :user_id
  validates_presence_of     :category_id
  validates_inclusion_of    :category_id, :in => 1..8

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :with_user,   :include => :user
  named_scope :with_store,  :include => :store
  named_scope :by_id,       'id DESC'
  named_scope :for_user,    lambda {|user_id| 
                              {:conditions => {:user_id => user_id}}}
  named_scope :in_category, lambda {|category_id| 
                              {:conditions => {:category_id => category_id}}}


  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :is_store_unknown

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new product
  #
  def self.add(attributes,user_id)
    create!(
      :title            => attributes['title'],
      :source_url       => attributes['source_url'],
      :orig_image_url   => attributes['orig_image_url'],
      :orig_thumb_url   => attributes['orig_thumb_url'],
      :is_hosted        => attributes['is_hosted'],
      :query            => attributes['query'],
      :price            => attributes['price'],
      :endorsement      => attributes['endorsement'].strip,
      :is_gift          => attributes['is_gift'],
      :category_id      => attributes['category_id'],
      :store_id         => attributes['store_id'],
      :user_id          => user_id)
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Edit attributes of the model
  #
  def edit(attributes)

    validate = true
    
    if !attributes[:endorsement].nil?
      self.endorsement = attributes[:endorsement]
      validate = false
    end

    self.save(validate)
  end

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

    file_path        = Tempfile.new(image_path).path

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
      image = MiniMagick::Image.from_file(file_path)

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
      image = MiniMagick::Image.from_file(file_path)

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
  end

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]      = [] if options[:only].nil?
    options[:only]     += [:id,:title,:endorsement,:handle,:price,:comments_count]

    options[:methods]   = [:thumbnail_url]

    options[:include] = {}
    options[:include].store(*(Store.json_options))

    super(options)
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
