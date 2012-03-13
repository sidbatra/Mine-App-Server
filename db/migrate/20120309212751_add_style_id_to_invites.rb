class AddStyleIdToInvites < ActiveRecord::Migration
  def self.up
    add_column  :invites, :style_id, :integer
    add_index   :invites, :style_id

    remove_column :invites, :byline
  end

  def self.down
    remove_column :invites, :style_id  

    add_column :invites, :byline, :string
  end
end
