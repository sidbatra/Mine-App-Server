class Notification < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  belongs_to  :user
  belongs_to  :resource,  :polymorphic => true

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates_presence_of   :user_id
  validates_presence_of   :entity
  validates_presence_of   :event
  validates_presence_of   :resource_id
  validates_presence_of   :resource_type
  validates_presence_of   :image_url
  validates_inclusion_of  :identifier, :in => NotificationIdentifier.values

  #-----------------------------------------------------------------------------
  # Named scopes
  #-----------------------------------------------------------------------------
  named_scope :of, lambda{|resource| {:conditions => {
                                      :resource_id => resource.id,
                                      :resource_type => resource.class.name}}}
  named_scope :for, lambda{|user_id| {:conditions => {
                                      :user_id => user_id}}}

  #-----------------------------------------------------------------------------
  # Class methods
  #-----------------------------------------------------------------------------

  def self.add(user_id,entity,event,resource,image_url,identifier)
    notification = find_or_initialize_by_user_id_and_resource_id_and_resource_type_and_identifier(
                    :user_id => user_id,
                    :resource_id => resource.id,
                    :resource_type => resource.class.name,
                    :identifier => identifier)

      notification.entity = entity
      notification.event = event
      notification.image_url = image_url
      notification.unread = true

      notification.save!
  end


  #-----------------------------------------------------------------------------
  # Instance methods
  #-----------------------------------------------------------------------------
  
  def read
    self.unread = false
    save!
  end

end
