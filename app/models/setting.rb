class Setting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :post_to_timeline
end
