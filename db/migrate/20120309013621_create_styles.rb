class CreateStyles < ActiveRecord::Migration
  def self.up
    create_table :styles do |t|
      t.string :title
      t.string :image_path
      t.integer :weight, :default => 0

      t.timestamps
    end

    change_column :suggestions, :image_path, :string, :null => nil
  end

  def self.down
    drop_table :styles
  end
end
