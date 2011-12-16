class Action < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :actionable, :polymorphic => true, :counter_cache => true

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :name
  validates_inclusion_of  :name, :in => %w(like own want)
  validates_presence_of   :user_id
  validates_presence_of   :actionable_id
  validates_presence_of   :actionable_type
  validates_inclusion_of  :actionable_type, :in => %w(Product)

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :with_user, :include => :user
  named_scope :on, lambda {|klass,id| 
                            {:conditions => {
                              :actionable_id    => id,
                              :actionable_type  => klass.capitalize}}}
  named_scope :by_id, :order => 'id DESC'

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  # Add a new action
  #
  def self.add(attributes,user_id)
    find_or_create_by_actionable_id_and_actionable_type_and_name_and_user_id(
      :actionable_id      => attributes['source_id'],
      :actionable_type    => attributes['source_type'].capitalize,
      :name               => attributes['name'],
      :user_id            => user_id)
  end

  # Fetch an ownership entry for by a particular owner
  # on a particular actionable entity
  # return nil if not found
  #
  def self.fetch_own_on_for_user(klass,id,user_id)
    find_by_actionable_id_and_actionable_type_and_name_and_user_id(
      id,klass,'own',user_id)
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]  = [] if options[:only].nil?
    options[:only] += [:id,:name,:user_id]

    options[:include] = {}
    options[:include].store(*(User.json_options))

    super(options)
  end

end
