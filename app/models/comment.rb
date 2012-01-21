class Comment < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of   :data
  validates_presence_of   :user_id
  validates_presence_of   :commentable_id
  validates_presence_of   :commentable_type
  validates_inclusion_of  :commentable_type, :in => %w(Product)

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :with_user, :include => :user
  named_scope :on, lambda {|klass,id| {:conditions => {
                              :commentable_id   => id,
                              :commentable_type => klass.capitalize}}}
  named_scope :by_id, :order => 'id DESC'

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Add a new comment
  #
  def self.add(attributes,user_id)
    create!(
      :data             => attributes['data'],
      :commentable_id   => attributes['source_id'],
      :commentable_type => attributes['source_type'].capitalize,
      :user_id          => user_id)
  end

  # Fetch all the user ids participating in the comment thread on
  # for the given commentable details
  #
  def self.user_ids_in_thread_with(comment)
    user_ids = all(
                :select     => 'user_id',
                :conditions => {
                  :commentable_type => comment.commentable_type,
                  :commentable_id   => comment.commentable_id}).map(&:user_id)
    user_ids << comment.commentable.user_id
    user_ids.uniq
  end


  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id,:data,:created_at]

    options[:include] = {}
    options[:include].store(*(User.json_options))

    super(options)
  end

end
