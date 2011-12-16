class AddSourceToSearches < ActiveRecord::Migration
  def self.up
    add_column :searches, :source, :string
    add_index :searches, :source
  end

  def self.down
    remove_column :searches, :source
    remove_index :searches, :source
  end
end
