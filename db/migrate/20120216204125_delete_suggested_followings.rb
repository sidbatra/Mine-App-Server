class DeleteSuggestedFollowings < ActiveRecord::Migration
  def self.up

    ids = Following.find_all_by_source(FollowingSource::Suggestion).map(&:id)
    Following.delete_all(:id => ids) 

    columns = [:id,:followings_count,:inverse_followings_count]
    values  = User.all(:include => [:followers, :ifollowers]).
                    map{|u| [u.id,u.followers.length,u.ifollowers.length]}

    User.import columns, values, 
      {:validate => false, 
      :on_duplicate_key_update => [:followings_count,
                                   :inverse_followings_count,
                                   :updated_at]}

  end

  def self.down
  end
end
