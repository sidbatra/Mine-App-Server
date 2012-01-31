class Specialty < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to  :store
  belongs_to  :category

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :store_id
  validates_presence_of   :category_id
  validates_presence_of   :weight
  validates_inclusion_of  :is_top, :in => [true,false]

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Add or update a specialty
  #
  def self.add(store_id,category_id,weight,is_top)

    specialty = Specialty.find_or_initialize_by_store_id_and_category_id(
                  :store_id     => store_id,
                  :category_id  => category_id)

    specialty.weight = weight
    specialty.is_top = is_top

    specialty.save!
    specialty
  end

end
