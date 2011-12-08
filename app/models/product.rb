class Product < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Mixins
  #-----------------------------------------------------------------------------
  include DW::Handler

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user,  :counter_cache => true
  belongs_to  :store, :counter_cache => true
  belongs_to  :category
  has_many    :comments, :as => :commentable, :dependent => :destroy
  has_many    :actions,  :as => :actionable, :dependent => :destroy
  has_many    :collection_parts, :dependent => :destroy

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of     :title
  validates_presence_of     :price
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
  named_scope :by_id,       :order => 'id DESC'
  named_scope :by_actions,  :order => 'actions_count DESC,id DESC'
  named_scope :limit,       lambda {|limit| {:limit => limit}}
  named_scope :for_ids,     lambda {|ids| {:conditions => {:id => ids}}}
  named_scope :for_user,    lambda {|user_id| 
                              {:conditions => {:user_id => user_id}}}
  named_scope :for_store,   lambda {|store_id| 
                              {:conditions => {:store_id => store_id}}}
  named_scope :in_category, lambda {|category_id| 
                              {:conditions => {:category_id => category_id}} if category_id}
  named_scope :created,     lambda {|range| 
                              {:conditions => {:created_at => range}}}


  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :is_store_unknown, :store_name, :rehost
  attr_accessible :title,:source_url,:orig_image_url,:orig_thumb_url,:is_hosted,
                  :query,:price,:endorsement,:is_gift,:category_id,
                  :store_id,:user_id,:source_product_id

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new product
  #
  def self.add(attributes,user_id)
    create!(
      :title              => attributes['title'],
      :source_url         => attributes['source_url'],
      :orig_image_url     => attributes['orig_image_url'],
      :orig_thumb_url     => attributes['orig_thumb_url'],
      :is_hosted          => attributes['is_hosted'],
      :query              => attributes['query'],
      :price              => attributes['price'],
      :endorsement        => attributes['endorsement'].strip,
      :is_gift            => attributes['is_gift'],
      :category_id        => attributes['category_id'],
      :store_id           => attributes['store_id'],
      :source_product_id  => attributes['source_product_id'],
      :user_id            => user_id)
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Share the product to fb via the user who created it
  #
  #def share(product_url)
  #  fb_user = FbGraph::User.me(self.user.access_token)
  #  fb_user.feed!(
  #    :message      => self.endorsement,
  #    :picture      => self.thumbnail_url,
  #    :link         => product_url,
  #    :description  => user.first_name + " is using #{CONFIG[:name]} to share " +
  #                      (user.is_male? ? "his" : "her") +
  #                      " online closet. It's fun, and free!",
  #    :name         => self.title)
  #end

  # Mark the product as gift
  #
  def make_gift
    self.is_gift  = true
    self.price    = 0
    self.store_id = nil
    save!
  end

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
    options[:only]     += [:id,:title,:is_gift,:endorsement,:handle,:price,
                            :comments_count,:user_id]

    options[:methods]   = [] if options[:methods].nil?
    options[:methods]  += [:thumbnail_url]

    options[:include] = {}
    options[:include].store(*(Store.json_options)) if options[:with_store]
    options[:include].store(*(User.json_options(:methods => []))) if options[:with_user]

    super(options)
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
