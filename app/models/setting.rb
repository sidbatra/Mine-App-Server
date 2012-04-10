class Setting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :post_to_timeline, :email_interaction, 
                    :email_influencer, :email_update,
                    :fb_publish_stream

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :post_to_timeline, :in => [true,false]
  validates_inclusion_of  :email_interaction, :in => [true,false]
  validates_inclusion_of  :email_influencer, :in => [true,false]
  validates_inclusion_of  :email_update, :in => [true,false]
  validates_inclusion_of  :fb_publish_actions, :in => [true,false]
  validates_inclusion_of  :fb_publish_stream, :in => [true,false]
end
