class MoveSearchesSourceToInteger < ActiveRecord::Migration
  def self.up
    Search.update_all(
      {:source => SearchSource::New},
      {:source => 'new'})

    Search.update_all(
      {:source => SearchSource::Edit},
      {:source => 'edit'})

    change_column :searches, :source, :integer
  end

  def self.down
    change_column :searches, :source, :string

    Search.update_all(
      {:source => 'new'},
      {:source => SearchSource::New})

    Search.update_all(
      {:source => 'edit'},
      {:source => SearchSource::Edit})
  end
end
