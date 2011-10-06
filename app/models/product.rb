class Product < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :title
  validates_presence_of   :endorsement
  validates_presence_of   :image_url
  validates_presence_of   :user_id

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new product
  #
  def add(attributes)
    create(
      :title        => attributes['title'],
      :endorsement  => attributes['endorsement'],
      :website_url  => attributes['website_url'],
      :image_url    => attributes['image_url'],
      :user_id      => attributes['user_id'])
  end

  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

end
