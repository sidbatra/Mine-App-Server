class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string  :data
      t.integer :user_id
      t.integer :product_id

      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, :product_id
  end

  def self.down
    drop_table :comments
  end
end
