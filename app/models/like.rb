class Like < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user
  belongs_to :purchase

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :purchase_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user, :include => :user

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new like 
  #
  def self.add(purchase_id,user_id)
    create!(
      :purchase_id      => purchase_id, 
      :user_id          => user_id)
  end

  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Full name of like owner 
  # 
  def name 
    self.user.full_name
  end
  
  # Facebook user id of the like owner
  #
  def fb_user_id
    self.user.fb_user_id
  end

end
