class Contact < ActiveRecord::Base
  
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Batch insert of user's facebook contacts
  #
  def self.batch_insert(user_id,fb_friends_ids,fb_friends_names)
    fields  = [:user_id, :third_party_id, :name] 
    data    = ([user_id]*fb_friends_ids.length).zip(
                                              fb_friends_ids,
                                              fb_friends_names)
    
    import fields,data
  end

  # Create contact from facebook friend object
  #
  def self.from_fb_friend(user_id,fb_friend)
    new({ 
        :user_id        => user_id,
        :third_party_id => fb_friend.identifier,
        :name           => fb_friend.name})
  end

  #----------------------------------------------------------------------
  # Instance methods
  #----------------------------------------------------------------------

  # Override to customize accessible attributes
  #
  def to_json(options = {})
    options[:only]      = [] if options[:only].nil?
    options[:only]     += [:id,:third_party_id,:name]

    options[:methods]   = [] if options[:methods].nil?

    super(options)
  end

end
