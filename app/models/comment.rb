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

  # Fetch all the user ids participating in the comment thread on
  # for the given commentable details
  #
  def self.user_ids_in_thread_with(comment)
    user_ids = all(
                :select     => 'user_id',
                :conditions => {:purchase_id => comment.purchase_id}
                ).map(&:user_id)
    user_ids << comment.purchase.user_id
    user_ids.uniq
  end

  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Facebook like user object of the comment owner 
  # 
  def from
    {:name  => self.user.full_name,
     :id    => self.user.fb_user_id}
  end

end
