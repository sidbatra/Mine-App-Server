class Contact < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to :user

  #-----------------------------------------------------------------------------
  # Class Methods 
  #-----------------------------------------------------------------------------

  # Add a new contact 
  #
  def self.add(user_id,third_party_id)
    find_or_create_by_user_id_and_third_party_id(
      :user_id          => user_id,
      :third_party_id   => third_party_id)
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]      = [] if options[:only].nil?
    options[:only]     += [:id,:third_party_id,:name]

    options[:methods]   = [] if options[:methods].nil?

    super(options)
  end

end
