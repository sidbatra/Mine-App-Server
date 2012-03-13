class AddSuggestionIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :suggestion_id, :integer
    add_index :products, :suggestion_id
  end

  def self.down
    remove_column :products, :suggestion_id
  end
end
