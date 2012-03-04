class Contact < ActiveRecord::Base
  
  #----------------------------------------------------------------------
  # Associations
  #----------------------------------------------------------------------
  belongs_to :user
  has_one :fb_user, 
              :class_name => "User", 
              :foreign_key => "fb_user_id",
              :primary_key => "third_party_id"
  
  #----------------------------------------------------------------------
  # Named Scopes
  #----------------------------------------------------------------------
  named_scope :by_name, :order => :name
  named_scope :for_user, lambda {|user_id| {
                :conditions => {:user_id => user_id}}}

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

end
