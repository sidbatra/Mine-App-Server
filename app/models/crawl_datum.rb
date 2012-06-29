class CrawlDatum < ActiveRecord::Base
  belongs_to :store
  attr_accessible :active, :launch_url

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :store_id
  validates_inclusion_of :active, :in => [true,false]
end
