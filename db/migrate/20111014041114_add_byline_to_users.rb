class AddBylineToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :byline, :string, :default => ""
  end

  def self.down
    remove_column :users, :byline
  end
end
