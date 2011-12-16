class PopulateSourcesForFollowingsAndSearches < ActiveRecord::Migration
  def self.up
    Following.all(:include => [:user,:follower]).each do |f|
      if (f.created_at - f.user.created_at).abs < 120 || 
          (f.created_at - f.follower.created_at).abs < 120

        f.source = 'auto'
      else 
        f.source = 'manual'
      end
      
      f.save!
    end

    Search.update_all(:source => 'new')
  end

  def self.down
    Following.update_all(:source => nil)
    Search.update_all(:source => nil)
  end
end
