class AddIndexOnSuggestionThing < ActiveRecord::Migration
  def self.up
    add_index :suggestions, :thing
  end

  def self.down
    remove_index :suggestions, :thing
  end
end
