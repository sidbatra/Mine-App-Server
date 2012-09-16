class CreateThemes < ActiveRecord::Migration
  def self.up
    create_table :themes do |t|
      t.string :background_path
      t.string :background_tile_path
      t.string :background_body_class
      t.integer :weight, :default => 0

      t.timestamps
    end

    add_index :themes, :weight
  end

  def self.down
    drop_table :themes
  end
end
