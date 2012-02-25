class Setting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :post_to_timeline, :email_interaction, 
                    :email_influencer, :email_update

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :post_to_timeline, :in => [true,false]
end
