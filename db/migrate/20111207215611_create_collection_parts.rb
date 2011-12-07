class CreateCollectionParts < ActiveRecord::Migration
  def self.up
    create_table :collection_parts do |t|
      t.integer :collection_id
      t.integer :product_id

      t.timestamps
    end

    add_index :collection_parts, :collection_id
    add_index :collection_parts, :product_id
  end

  def self.down
    drop_table :collection_parts
  end
end
