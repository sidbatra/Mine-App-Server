class Purchase < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Mixins
  #----------------------------------------------------------------------
  include DW::Handler

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user, :touch => true, :counter_cache => true
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
  named_scope :for_users, lambda {|users| {:conditions => {
                            :user_id => users.map(&:id)}}}
  named_scope :with_user,  :include => :user
  named_scope :with_store, :include => :store
  named_scope :by_id,      :order => 'id DESC'

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessor :is_store_unknown, :store_name, :rehost
  attr_accessible :title,:source_url,:orig_image_url,:orig_thumb_url,
                  :query,:store_id,:user_id,
                  :source_purchase_id,:suggestion_id,
                  :fb_action_id,:fb_photo_id

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

  # Factory method to create a new purchase.
  #
  # returns - Purchase. Newly created purchase object.
  #
  def self.add(attributes,user_id)
    attributes[:title]        = attributes[:title].strip
    attributes[:user_id]      = user_id

    create!(attributes)
  end

  # Perform full text search on all the indexed purchases using 
  # solr + sunpot.
  #
  # query - String. Full text search query.
  # page - Integer:1. Pagination - the page of results to fetch
  # per_page - Integer:10. Pagination - number of results per page
  # 
  # returns - Array. Array of purchase models matching the given query.
  #
  def self.fulltext_search(query,page=1,per_page=10)
    search do 
      fulltext query
      paginate :per_page => per_page, :page => page
    end.results
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

  # Opengraph object id associated with the purchase
  #
  def fb_object_id
    self.fb_photo_id ? self.fb_photo_id : self.fb_action_id
  end

  # Facebook post associated with the purchase
  #
  def fb_post
    fb_post = nil

    if self.fb_photo_id
      fb_post = FbGraph::Photo.new(self.fb_photo_id)
    elsif self.fb_action_id
      fb_post = FbGraph::OpenGraph::Action.new(self.fb_action_id)
    end

    fb_post
  end

  # Url for fetching facebook comments of the object (photo/action)
  # associated with the purchase
  #
  def fb_comments_url
    "https://graph.facebook.com/#{self.fb_object_id}/comments?" \
    "access_token=#{self.user.access_token}"
  end

  # Url for fetching facebook likes of the object (photo/action)
  # associated with the purchase
  #
  def fb_likes_url
    "https://graph.facebook.com/#{self.fb_object_id}/likes?" \
    "access_token=#{self.user.access_token}"
  end

  # Returns whether or not the purchase should be shared 
  # to facebook timeline
  #
  def share_to_fb_timeline?
    self.fb_action_id == FBSharing::Underway
  end

  # Returns whether or not the purchase should be shared 
  # to facebook photo album 
  #
  def share_to_fb_album?
    self.fb_photo_id == FBSharing::Underway
  end
  
  # Returns if the purchase sharing on facebook has finished 
  #
  def shared?
    self.fb_object_id.present? & (self.fb_object_id != FBSharing::Underway) 
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
                        {:width => 180,:height => 180})

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
                        {:width => 520,:height => 390})

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
