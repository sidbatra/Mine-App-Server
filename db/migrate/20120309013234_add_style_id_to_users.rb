class AddStyleIdToUsers < ActiveRecord::Migration
  def self.up
    add_column  :users, :style_id, :integer
    add_index   :users, :style_id
  end

  def self.down
    remove_column :users, :style_id
  end
end
