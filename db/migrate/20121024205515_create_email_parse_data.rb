class CreateEmailParseData < ActiveRecord::Migration
  def self.up
    create_table :email_parse_data do |t|
      t.integer :store_id
      t.boolean :is_active, :default => false
      t.string :emails

      t.timestamps
    end

    columns = [:store_id]
    values = []

    Store.select(:id).each do |store|
      values << [store.id]
    end

    EmailParseDatum.import columns,values,{:validate => false}

    add_index :email_parse_data, :store_id, :unique => true
    add_index :email_parse_data, :is_active
  end

  def self.down
    drop_table :email_parse_data
  end
end
