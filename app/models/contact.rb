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
  named_scope :by_weight, :order => "weight DESC"
  named_scope :with_fb_user, :include => :fb_user
  named_scope :for_user, lambda {|user_id| {
                :conditions => {:user_id => user_id}}}

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :user_id,:third_party_id,:name,:created_at,:updated_at

  #----------------------------------------------------------------------
  # Class Methods 
  #----------------------------------------------------------------------

  # Batch insert contacts for a particular user.
  #
  # user_id : Integer. User id whose contacts are being added.
  # third_party_ids : Array. Unique identifiers for each of the contacts.
  # names : Array. Names for each of the contacts.
  #
  def self.batch_insert(user_id,third_party_ids,names)
    if third_party_ids.length != names.length
      raise IOError, "ids and names Array lengths aren't equal" 
    end

    fields = [:user_id,:third_party_id,:name] 
    data = ([user_id]*third_party_ids.length).zip(third_party_ids,names)
    
    import fields,data
  end


  #----------------------------------------------------------------------
  # Instance Methods 
  #----------------------------------------------------------------------

  # Image url for the contact.
  #
  # returns String image path or nil if not found.
  #
  def image_url
    "http://graph.facebook.com/#{third_party_id}/picture?type=square"
  end

end
