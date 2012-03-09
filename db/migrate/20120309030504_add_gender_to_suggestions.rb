class AddGenderToSuggestions < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :gender, :integer, :default => SuggestionGender::Neutral
    add_index :suggestions, :gender
  end

  def self.down
    remove_column :suggestions, :gender
  end
end
