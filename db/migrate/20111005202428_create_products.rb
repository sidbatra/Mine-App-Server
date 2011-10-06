class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string  :title
      t.string  :handle
      t.string  :endorsement
      t.text    :website_url
      t.text    :image_url
      t.string  :query
      t.integer :user_id

      t.timestamps
    end

    add_index :products, :user_id
  end

  def self.down
    drop_table :products
  end
end
