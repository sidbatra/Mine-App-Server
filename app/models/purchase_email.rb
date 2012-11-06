class PurchaseEmail < ActiveRecord::Base
  belongs_to :purchase
  attr_accessible :message_id,:provider,:text

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_presence_of :message_id
  validates_presence_of :provider
  validates_inclusion_of :provider, :in => EmailProvider.values
  validates_presence_of :text
end
