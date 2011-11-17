class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.integer :product_id
      t.integer :user_id
      t.string :name

      t.timestamps
    end

    add_index :actions,[:user_id,:name]
    add_index :actions,[:product_id,:name,:user_id], :unique => true

    add_column :products, :actions_count, :integer, :default => 0
  end

  def self.down
    drop_table :actions
  end
end
