class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.integer :variable
      t.string :value

      t.timestamps
    end

    add_index :configurations, :variable, :unique => true
  end

  def self.down
    drop_table :configurations
  end
end
