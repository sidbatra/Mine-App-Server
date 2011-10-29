class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.string :handle

      t.timestamps
    end

    add_index :categories, :handle, :unique => true
  end

  def self.down
    drop_table :categories
  end
end
