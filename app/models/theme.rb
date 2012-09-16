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
end
