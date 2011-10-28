class CreateStores < ActiveRecord::Migration
  def self.up
    create_table :stores do |t|
      t.string  :name
      t.integer :user_id
      t.integer :products_count, :default => 0

      t.timestamps
    end

    add_index :stores, :name, :unique => true
  end

  def self.down
    drop_table :stores
  end
end
