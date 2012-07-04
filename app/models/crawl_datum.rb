class CrawlDatum < ActiveRecord::Base
  belongs_to :store
  attr_accessible :active, :launch_url, :use_og_image

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :store_id
  validates_inclusion_of :active, :in => [true,false]
end
