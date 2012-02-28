class ChangeSearchQueryToText < ActiveRecord::Migration
  def self.up
    change_column :searches, :query, :text
  end

  def self.down
    change_column :searches, :query, :string
  end
end
