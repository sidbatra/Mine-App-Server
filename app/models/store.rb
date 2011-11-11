class Store < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user
  has_many    :products

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :name
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :approved,    :conditions => {:is_approved => true}
  named_scope :unapproved,  :conditions => {:is_approved => false}
  named_scope :sorted,      :order      => 'name ASC'
  named_scope :popular,     :order      => 'products_count DESC'

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new store
  #
  def self.add(name,user_id)
    find_or_create_by_name(
      :name     => name.squeeze(' ').strip,
      :user_id  => user_id)
  end

  # Fetch a store by name 
  #
  def self.fetch(name)
    find_by_name(name.squeeze(' ').strip) 
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Edit attributes of the model
  #
  def edit(attributes)

    if attributes[:name].present?
      self.name = attributes[:name]
    end

    if attributes[:is_approved].present?
      self.is_approved  = attributes[:is_approved] 
    end

    self.save!
  end

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    super(options.merge(:only => [:id,:name]))
  end

  # Move all products to an existing store
  #
  def move_products_to(store)
      products_updated  = Product.update_all(
                            {:store_id => store.id},
                            {:store_id => self.id})

      Store.update_counters(
              store.id,
              :products_count => products_updated)
  end

end
