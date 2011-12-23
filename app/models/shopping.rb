class Shopping < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :store

  #-----------------------------------------------------------------------------
  # Validations 
  #-----------------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :store_id
  validates_presence_of   :source
  validates_inclusion_of  :source, :in => ShoppingSource.values

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :store_ids

  #-----------------------------------------------------------------------------
  # Class Methods 
  #-----------------------------------------------------------------------------

  # Add a new shopping 
  #
  def self.add(user_id,store_id,source)
    shopping = find_or_create_by_user_id_and_store_id(
                  :user_id      => user_id,
                  :store_id     => store_id,
                  :source       => source)
  end

end
