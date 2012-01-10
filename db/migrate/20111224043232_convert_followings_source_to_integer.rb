class ConvertFollowingsSourceToInteger < ActiveRecord::Migration
  def self.up
    Following.update_all(
      {:source => FollowingSource::Auto},
      {:source => 'auto'})

    Following.update_all(
      {:source => FollowingSource::Manual},
      {:source => 'manual'})

    Following.update_all(
      {:source => FollowingSource::Suggestion},
      {:source => 'suggestion'})
    
    change_column :followings, :source, :integer
  end

  def self.down
    change_column :followings, :source, :string

    Following.update_all(
      {:source => 'auto'},
      {:source => FollowingSource::Auto})

    Following.update_all(
      {:source => 'manual'},
      {:source => FollowingSource::Manual})

    Following.update_all(
      {:source => 'suggestion'},
      {:source => FollowingSource::Suggestion})
  end
end
