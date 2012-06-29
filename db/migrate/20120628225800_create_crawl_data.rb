class CreateCrawlData < ActiveRecord::Migration
  def self.up
    create_table :crawl_data do |t|
      t.integer :store_id
      t.boolean :active, :default => false
      t.string :launch_url
      t.datetime :crawled_at

      t.timestamps
    end


    columns = [:store_id,:active,:launch_url]
    values = []

    Store.all.each do |store|
      values << [store.id,
                  store.crawlable,
                  store.crawlable ? "http://#{store.domain}" : nil]
    end

    CrawlDatum.import columns, values, {:validate => false}


    add_index :crawl_data, :store_id, :unique => true
    add_index :crawl_data, :active
    add_index :crawl_data, :crawled_at
  end

  def self.down
    drop_table :crawl_data
  end
end
