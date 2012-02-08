class Collection < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user, :counter_cache => true
  has_many :collection_parts, :dependent => :destroy
  has_many :products, :through => :collection_parts

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :user_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :for_user, lambda {|user_id| {:conditions => {
                                              :user_id => user_id}}}
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :by_id, :order => 'id DESC'
  named_scope :with_products, :include => :products
  named_scope :with_products_and_associations,
              :include => {:products => [:store,:user]}
  named_scope :with_user, :include => :user

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :name,:user_id

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new collection
  #
  def self.add(product_ids,name,user_id)
    collection = new(
                  :user_id  => user_id,
                  :name     => name)

    raise IOError, "No products added to collection" unless product_ids.present?

    product_ids.uniq.each do |product_id|
      collection.collection_parts.build(:product_id => product_id)
    end

    collection.save!
    collection
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Destroy the old collection parts and make new ones
  #
  def update_parts(new_product_ids)
    collection_parts.destroy_all

    new_product_ids.uniq.each do |product_id|
      collection_parts.build(:product_id => product_id)
    end

    save!
  end

  # Fetch the next collection made by the owner 
  #
  def next
    self.class.first(
                :conditions => {
                    :user_id  => self.user_id,
                    :id_gt    => self.id})
  end

  # Fetch the previous collection made by the owner 
  #
  def previous
    self.class.last(
                :conditions => {
                    :user_id  => self.user_id,
                    :id_lt    => self.id})
  end

end
