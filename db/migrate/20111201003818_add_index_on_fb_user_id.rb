class AddIndexOnFbUserId < ActiveRecord::Migration
  def self.up
    User.find_all_by_fb_user_id("").each{|u| u.destroy}
    User.find_all_by_fb_user_id(100002927884677).first.destroy
    add_index :users, :fb_user_id, :unique => true
  end

  def self.down
    remove_index :users, :fb_user_id
  end
end
