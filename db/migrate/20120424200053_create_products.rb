class CreateProducts < ActiveRecord::Migration
  def self.up
    database = Rails.configuration.database_configuration[Rails.env]["database"]
    sql = "alter database #{database} default character set utf8 collate utf8_unicode_ci"
    ActiveRecord::Base.connection.execute sql

    create_table :products do |t|
      t.string :title
      t.text :description
      t.text :source_url
      t.text :orig_image_url
      t.string :orig_image_url_hash
      t.string :image_path
      t.boolean :is_processed, :default => false
      t.integer :store_id
      t.string :external_id

      t.timestamps
    end

    add_index :products, :orig_image_url_hash, :unique => true
  end

  def self.down
    drop_table :products
  end
end
