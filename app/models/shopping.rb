class Shopping < ActiveRecord::Base
  
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user, :counter_cache => true
  belongs_to :store

  #----------------------------------------------------------------------
  # Validations 
  #----------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :store_id
  validates_presence_of   :source
  validates_inclusion_of  :source, :in => ShoppingSource.values

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Add a new shopping 
  #
  def self.add(user_id,store_id,source)
    shopping = find_or_create_by_user_id_and_store_id(
                  :user_id      => user_id,
                  :store_id     => store_id,
                  :source       => source)
  end

  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Increment the products count
  #
  def increment_products_count
    self.increment!(:products_count)
  end

  # Decrement the products count
  #
  def decrement_products_count
    self.decrement!(:products_count)

    if self.products_count.zero? && self.source == ShoppingSource::Product
      self.destroy
    end
  end

end
