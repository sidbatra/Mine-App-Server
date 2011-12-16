class AddSourceToFollowings < ActiveRecord::Migration
  def self.up
    add_column :followings, :source, :string
    add_index :followings, :source
  end

  def self.down
    remove_column :followings, :source
    remove_index :followings, :source
  end
end
