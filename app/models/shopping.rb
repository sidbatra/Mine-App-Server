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
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :by_count, :order => 'purchases_count DESC'
  named_scope :with_store, :include => :store

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Factory method for creating a new shopping.
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

  # Increment the purchases count.
  #
  def increment_purchases_count
    self.increment!(:purchases_count)
  end

  # Decrement the purchases count and destroy the record
  # if the purchases_count goes down to zero.
  #
  def decrement_purchases_count
    self.decrement!(:purchases_count)

    if self.purchases_count.zero? && self.source == ShoppingSource::Purchase
      self.destroy
    end
  end

end
