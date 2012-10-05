class Theme < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :background_path
  validates_presence_of   :background_tile_path

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :background_path,:background_tile_path,:background_body_class,
                  :weight

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :by_weight, :order => 'weight DESC'


  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  def self.default
    find(7)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Full url of the background image.
  #
  def background_url
    FileSystem.url(background_path)
  end

  # Full url of the background tile image.
  #
  def background_tile_url
    FileSystem.url(background_tile_path)
  end
end
