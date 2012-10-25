class Purchase < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_one  :purchase_email, :dependent => :destroy 
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :notifications, :as => :resource, :dependent => :destroy
  belongs_to :user, :touch => true, :counter_cache => true
  belongs_to :store, :counter_cache => true
  belongs_to :product
  belongs_to :suggestion

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :title
  validates_presence_of :orig_image_url
  validates_presence_of :user_id
  validates_inclusion_of :source, :in => PurchaseSource.values

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :for_users, lambda {|users| {:conditions => {
                            :user_id => users.map(&:id)}}}
  named_scope :bought_after, lambda{|time| {:conditions => {
                                              :bought_at_gt => time}} if time}
  named_scope :bought_before, lambda{|time| {:conditions => {
                                              :bought_at_lt => time}} if time}
  named_scope :with_user,  :include => :user
  named_scope :with_store, :include => :store
  named_scope :with_product,  :include => :product
  named_scope :with_likes, :include => {:likes => [:user]}
  named_scope :with_comments, :include => {:comments => [:user]}
  named_scope :special, :conditions => {:is_special => true}
  named_scope :approved, :conditions => {:is_approved => true}
  named_scope :unapproved, :conditions => {:is_approved => false}
  named_scope :by_id, :order => 'id DESC'
  named_scope :by_created_at, :order => 'created_at ASC'
  named_scope :by_bought_at, :order => 'bought_at DESC'

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :is_store_unknown, :store_name, :rehost, :block_delayed_update
  attr_accessible :title,:source_url,:orig_image_url,:orig_thumb_url,
                  :query,:store_id,:user_id,:product_id,
                  :source_purchase_id,:suggestion_id,
                  :fb_action_id,:endorsement,:tweet_id,:tumblr_post_id,:is_special,
                  :is_approved,:source,:bought_at

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method to create a new purchase.
  #
  # returns - Purchase. Newly created purchase object.
  #
  def self.add(attributes,user_id)
    attributes[:title] = attributes[:title].strip
    attributes[:user_id] = user_id
    attributes[:bought_at] ||= Time.now

    product = Product.find_by_orig_image_url attributes[:orig_image_url]
    attributes[:product_id] = product.id if product


    purchase = new(attributes)

    unless attributes[:product_id]
      purchase.build_product({
        :title => attributes[:product][:title],
        :source_url => attributes[:source_url],
        :orig_image_url => attributes[:orig_image_url],
        :external_id => attributes[:product][:external_id]})
    end

    if attributes[:email]
      purchase.build_purchase_email(attributes[:email])
    end

    purchase.save!
    purchase
  end

  # Toggle between two modes of pagination. Based on bought_at
  # in desc order and based on created_at in asc order.
  #
  def self.page(opts,on_bought=true)
    if on_bought 
      by_bought_at.bought_after(opts[:after]).bought_before(opts[:before])
    else
      by_created_at.limit(opts[:per_page]).offset(opts[:page]*opts[:per_page])
    end
  end

  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Mark the purchase's store as unknown by setting store_id
  # to nil.
  #
  def make_store_unknown
    self.store_id = nil
    save!
  end

  # Fetch the next purchase created by the user who created
  # this purchase.
  #
  def next
    self.class.first(
      :conditions => {
        :user_id  => self.user_id,
        :id_gt    => self.id})
  end

  # Fetch the previous purchase created by the user who created
  # this purchase.
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
    "t_#{image_path}"
  end

  # Public. Path on the filesystem to the square image.
  #
  # returns the String path on the filesystem.
  #
  def square_path
    "s_#{image_path}"
  end

  # Public. Path on the filesystem to the blurred image.
  #
  # returns the String path on the filesystem.
  #
  def blur_path
    "b_#{image_path}"
  end

  # Path on filesystem for the processed hosted giant image.
  #
  def giant_path
    "g_#{image_path}"
  end

  # Public. Path on the filesystem to the processed unit for
  # a purchase.
  #
  # returns the String path on the filesystem.
  #
  def unit_path
    "u_" + image_path
  end

  # Conditional upon hosting and orig_thumb_url status.
  #
  def thumbnail_url
    is_processed ? 
      FileSystem.url(thumbnail_path) :
      (orig_thumb_url.present? ? orig_thumb_url : orig_image_url)
  end

  # Public. Absolute url on the filesystem for square_path.
  #
  # Returns the String absolute url.
  def square_url
    is_processed ?
      FileSystem.url(square_path) : 
      orig_image_url
  end

  # Public. Absolute url on the filesystem for the blur_path.
  #
  # Returns the String absolute url.
  def blur_url
    is_processed ?
      FileSystem.url(blur_path) : 
      orig_image_url
  end
  
  # Url of the giant copy of the image.
  #
  def giant_url
    is_processed ?
      FileSystem.url(giant_path) : 
      orig_image_url
  end

  # Public. Absolute url on the filesystem for unit_path.
  #
  # returns the String absolute url on the filesystem.
  #
  def unit_url
    is_processed ?
      FileSystem.url(unit_path) :
      orig_image_url
  end

  # Url of the largest copy of the image.
  #
  def image_url
    is_processed ?
      FileSystem.url(image_path) : 
      orig_image_url
  end

  # Opengraph object id associated with the purchase
  #
  def fb_object_id
    self.fb_action_id
  end

  # Facebook post associated with the purchase
  #
  def fb_post
    self.fb_action_id ? FbGraph::OpenGraph::Action.new(self.fb_action_id) : nil
  end

  # Url for fetching facebook comments of the object (photo/action)
  # associated with the purchase
  #
  def fb_comments_url(access_token)
    "https://graph.facebook.com/#{self.fb_object_id}?" \
    "access_token=#{access_token}&fields=id,comments&" \
    "comments.limit=50"
  end

  # Url for fetching facebook likes of the object (photo/action)
  # associated with the purchase
  #
  def fb_likes_url(access_token)
    "https://graph.facebook.com/#{self.fb_object_id}?" \
    "access_token=#{access_token}&fields=id,likes&" \
    "likes.limit=50"
  end

  # Returns whether or not the purchase should be shared 
  # to facebook timeline
  #
  def share_to_fb_timeline?
    self.fb_action_id == FBSharing::Underway
  end

  # Returns whether or not the purchase should be shared 
  # to twitter 
  #
  def share_to_twitter?
    self.tweet_id == TWSharing::Underway
  end

  # Returns whether or not the purchase should be shared 
  # to tumblr 
  #
  def share_to_tumblr?
    self.tumblr_post_id == TumblrSharing::Underway
  end

  # Returns if the purchase sharing on facebook has finished 
  #
  def shared?
    !self.native? & (self.fb_object_id != FBSharing::Underway) 
  end

  # Returns if the purchase is native to the mine network 
  #
  def native?
    self.fb_object_id.nil?
  end

  def deleted_from_fb
    #self.fb_action_id = nil
    #self.save!
  end

  # Temporary method for hosting blurred images for each purchase.
  #
  def host_blur
    self.is_processed = true

    # Create blurred thumbnail
    #
    image = MiniMagick::Image.open(square_url)

    image.combine_options do |canvas|
      canvas.blur "2.5x2.5"
    end

    FileSystem.store(
      blur_path,
      open(image.path),
      "Content-Type" => "image/jpeg",
      "Expires"      => 1.year.from_now.
                          strftime("%a, %d %b %Y %H:%M:%S GMT"))

    self.save!
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

      # Create tiny thumbnail
      #
      #image = MiniMagick::Image.open(file_path)

      #ImageUtilities.reduce_to_with_image(
      #                  image,
      #                  {:width => 180,:height => 180})

      #FileSystem.store(
      #  thumbnail_path,
      #  open(image.path),
      #  "Content-Type" => "image/jpeg",
      #  "Expires"      => 1.year.from_now.
      #                      strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create square thumbnail
      #
      base = MiniMagick::Image.open(File.join(
                                      RAILS_ROOT,
                                      IMAGES[:white_200x200]))
      image = MiniMagick::Image.open(file_path)

      base = base.composite(image) do |canvas|
        canvas.gravity "Center"
        canvas.geometry "200x200+0+0"
      end

      FileSystem.store(
        square_path,
        open(base.path),
        "Content-Type" => "image/jpeg",
        "Expires"      => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create blurred thumbnail
      #
      image = MiniMagick::Image.open(base.path)

      image.combine_options do |canvas|
        canvas.blur "2.5x2.5"
      end

      FileSystem.store(
        blur_path,
        open(image.path),
        "Content-Type" => "image/jpeg",
        "Expires"      => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))

      # Create giant thumbnail
      #
      image = MiniMagick::Image.open(file_path)

      ImageUtilities.reduce_to_with_image(
                        image,
                        {:width => 520,:height => 390})

      FileSystem.store(
        giant_path,
        open(image.path),
        "Content-Type" => "image/jpeg",
        "Expires"      => 1.year.from_now.
                            strftime("%a, %d %b %Y %H:%M:%S GMT"))


      # Create unit.
      #
      base = MiniMagick::Image.open(File.join(
                                      RAILS_ROOT,
                                      IMAGES[:fb_unit_base]))
      overlay = MiniMagick::Image.open(File.join(
                                        RAILS_ROOT,
                                        IMAGES[:fb_unit_overlay]))
      image = MiniMagick::Image.open(file_path)

      base = base.composite(image) do |canvas|
        canvas.quality "100"
        canvas.gravity "Center"
        canvas.geometry "407x407+0+0"
      end

      base = base.composite(overlay) do |canvas|
        canvas.quality "100"
        canvas.gravity "NorthWest"
        canvas.geometry "54x54+447+19"
      end

      FileSystem.store(
        unit_path,
        open(base.path),
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
