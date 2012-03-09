class Suggestion < ActiveRecord::Base
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_many :products

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :title
  validates_inclusion_of :gender, :in => SuggestionGender.values
  

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :title,:image_path,:weight,:gender

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :by_weight, :order => 'weight DESC'
  named_scope :except, lambda{|ids| {:conditions => 
                        {:id_ne => ids}} if ids.present?}

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new suggestion
  #
  def self.add(attributes)
    create(attributes)
  end

  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Absolute url of the image
  #
  def image_url
    FileSystem.url(image_path)
  end

end
