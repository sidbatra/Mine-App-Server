class Comment < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user
  belongs_to :purchase

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :message
  validates_presence_of   :user_id
  validates_presence_of   :purchase_id

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user, :include => :user

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new comment
  #
  def self.add(attributes,user_id)
    create!(
      :message          => attributes['message'],
      :purchase_id      => attributes['purchase_id'],
      :user_id          => user_id)
  end

end
