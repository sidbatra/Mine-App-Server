class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
      t.string :title, :null => false
      t.string :image_path, :null => false
      t.integer :weight, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :suggestions
  end
end
