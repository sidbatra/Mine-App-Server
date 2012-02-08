class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :user_id
      t.boolean :post_to_timeline, :default => false

      t.timestamps
    end

    columns = [:user_id]
    values  = User.select(:id).map{|u| [u.id]}

    Setting.import columns, values, {:validate => false}

    add_index :settings, :user_id, :unique => true
  end

  def self.down
    drop_table :settings
  end
end
