class CreateSpecialties < ActiveRecord::Migration
  def self.up
    create_table :specialties do |t|
      t.integer :store_id
      t.integer :category_id
      t.integer :weight, :default => 0
      t.boolean :is_top, :default => false

      t.timestamps
    end

    add_index :specialties,[:store_id,:category_id]
    add_index :specialties,[:store_id,:is_top]
    add_index :specialties,:category_id 
    add_index :specialties,:weight
  end

  def self.down
    drop_table :specialties
  end
end
