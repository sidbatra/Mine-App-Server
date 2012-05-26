class Suggestion < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  has_many :purchases

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
  named_scope :by_weight, :order => 'weight'
  named_scope :except, lambda{|ids| {:conditions => 
                        {:id_ne => ids}} if ids.present?}
  named_scope :for_gender, lambda{|gender| {:conditions =>
                            ["gender = #{SuggestionGender::Neutral} or "\
                             "gender = #{SuggestionGender.value_for(gender)}"]}}
  named_scope :with_purchases, :include => :purchases


  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method for creating a new suggestion.
  #
  def self.add(attributes)
    create(attributes)
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Absolute url of the suggestion image.
  #
  def image_url
    FileSystem.url(image_path)
  end

end
