class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string  :query
      t.integer :user_id

      t.timestamps
    end

    add_index :searches, :user_id
  end

  def self.down
    drop_table :searches
  end
end
