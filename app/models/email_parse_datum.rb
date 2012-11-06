class EmailParseDatum < ActiveRecord::Base
  belongs_to :store
  attr_accessible :is_active, :emails, :weight

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of :is_active, :in => [true,false]
end
